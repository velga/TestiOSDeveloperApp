//
//  TDARequestManager.m
//  TestiOSDeveloperApp
//
//  Created by Vladislava Kirichenko on 11/6/14.
//  Copyright (c) 2014 Vladislava Kirichenko. All rights reserved.
//

#import "TDARequestManager.h"
#import "TDADataManager.h"
#import "TDAConstants.h"
#import "Request+Utilities.h"
#import <SocketRocket/SRWebSocket.h>
#import <Reachability/Reachability.h>
#import <XMLReader-Arc/XMLReader.h>

@interface TDARequestManager () <SRWebSocketDelegate>

@property (retain, nonatomic) NSOperationQueue *operationQueue;
@property (retain, nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation TDARequestManager
{
    SRWebSocket *_webSocket;
    BOOL _hasInternetConnection;
}

+ (TDARequestManager *)sharedInstance
{
    static dispatch_once_t onceToken = 0;
    static TDARequestManager *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[TDARequestManager alloc] init] retain];
    });
    
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        //start checking Internet connection
        [self startObservingReachability];
        //use SocketRocket library to connect web socket
        [self connectWebSocet];
    }
    
    return self;
}

- (NSOperationQueue *)operationQueue
{
    if (!_operationQueue) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.name = @"requestsSendingQueue";
    }
    
    return _operationQueue;
}

- (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.timeStyle = NSDateFormatterMediumStyle;
    }
    
    return _dateFormatter;
}

- (void)startObservingCoreDataChanges
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDataModelChange:)
                                                 name:NSManagedObjectContextObjectsDidChangeNotification
                                               object:[[TDADataManager sharedInstance] managedObjectContext]];
}

- (void)dealloc
{
    [_webSocket release];
    [_operationQueue release];
    [_dateFormatter release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}


#pragma mark - Reachability

- (void)startObservingReachability
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    
    [reachability startNotifier];
}

- (void)reachabilityChanged:(NSNotification *)note
{
     Reachability* curReach = [note object];
    if (curReach.currentReachabilityStatus == NotReachable) {
        _hasInternetConnection = NO;
        [self.operationQueue setSuspended:YES];
    } else {
        _hasInternetConnection = YES;
        [self connectWebSocet];
    }
}


#pragma mark - Work with server

- (void)connectWebSocet
{
    _webSocket.delegate = nil;
    [_webSocket close];
    
    NSURL *url = [NSURL URLWithString:kServerURLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    _webSocket = [[SRWebSocket alloc] initWithURLRequest:request];
    _webSocket.delegate = self;
    [_webSocket open];
    
    //send notification about current connection status
    [self sendConnectionStatusNotification:@"Opening connection"];
}

//here we deal with objects been added to Core Data and trying to send them to the server
- (void)handleDataModelChange:(NSNotification *)note
{
    //objects being added to Core Data
    NSSet *insertedObjects = [note userInfo][NSInsertedObjectsKey];
    
    [insertedObjects enumerateObjectsUsingBlock:^(Request *request, BOOL *stop) {
        //use __block self to avoid retain circle
        __block TDARequestManager *blockSelf = self;
        if (!blockSelf) { return; }
        //here we add operation which would send data to server into operation queue
        [self.operationQueue addOperationWithBlock:^{
            [blockSelf sendDataToServer:request];
        }];
    }];
}

//method to send data to server using SocketRocket library
- (void)sendDataToServer:(Request *)request
{
    //send notification about object we are trying to send to server
    [self sendRequestNotification:request];
    
    switch ([request.requestFormat integerValue]) {
        case JSONFormat: {
            NSString *jsonString = [request createJSONRepresentation];
            if (jsonString) { [_webSocket send:jsonString]; }
            break;
        }
            
        case XMLFormat: {
            NSString *xmlString = [request createXMLRepresentation];
            if (xmlString) { [_webSocket send:xmlString]; }
            break;
        }
            
        case BinaryFormat: {
            NSData *data = [request createBinaryRepresentation];
            if (data) { [_webSocket send:data]; }
            break;
        }
            
        default:
            NSAssert(false, @"Unexpected format");
            break;
    }
}


#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    //send notification about current connection status
    [self sendConnectionStatusNotification:@"Connected"];
    //start operation queue if it was suspended
    [self.operationQueue setSuspended:NO];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    NSString *errorInfo = [NSString stringWithFormat:@"Websocket Failed With Error %@", error];
    [self sendErrorNotification: errorInfo];
    
    if (_hasInternetConnection) {
        //trying to recconect webSocket
        [self connectWebSocet];
    } else {
        //send notification about current connection status
        [self sendConnectionStatusNotification:@"Connection failded"];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    //send notification about current connection status
    [self sendConnectionStatusNotification:@"Closed"];
    [self connectWebSocet];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;
{
    //send notification with received object
    [self sendResponseNotification:message];
    
    NSDictionary *dict;
    //here we check in which format we received response
    if ([message isKindOfClass:[NSData class]]) {
        dict = [self retrieveDataFromBinaryDataResponse:(NSData *)message];
    } else if ([message isKindOfClass:[NSString class]]) {
        if ([self isXMLFormat:message]) {
            dict = [self retrieveDataFromXMLResponse:(NSString *)message];
        } else {
            dict = [self retrieveDataFromJSONResponse:(NSString *)message];
        }
    } else {
        NSAssert(false, @"Unexpected response class");
    }
    
    if (dict) {
        [self sendResponseDictionaryToCoreData:dict];
    }
}

//send dictionary to CoreData to chacge status of Request object
- (void)sendResponseDictionaryToCoreData:(NSDictionary *)dict
{
    [[TDADataManager sharedInstance] changeRequestStatus:dict];
}

- (BOOL)isXMLFormat:(NSString *)string
{
    NSAssert(string.length, @"String is empty");
    
    NSString *firstLetter = [string substringToIndex:1];
    NSString *lastLetter = [string substringFromIndex:(string.length - 1)];
    return [firstLetter isEqualToString:@"<"] && [lastLetter isEqualToString:@">"];
}

//parse json response into dictionary
- (NSDictionary *)retrieveDataFromJSONResponse:(NSString *)jsonString
{
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data
                                                             options:(NSJSONReadingOptions) kNilOptions
                                                               error:&error];
    
    if (!jsonDict) {
        NSLog(@"%@", error.localizedDescription);
        return nil;
    } else {
        NSDictionary *dict = @{kMessageParameter: jsonDict[kMessageParameter],
                               kBoolParameter: jsonDict[kBoolParameter],
                               kRequestFormat: @(JSONFormat)};
        return dict;
    }
}

//parse xml response into dictionary
- (NSDictionary *)retrieveDataFromXMLResponse:(NSString *)xmlString
{
    NSError *parseError = nil;
    NSDictionary *xmlDict = (NSMutableDictionary *)[XMLReader dictionaryForXMLString:xmlString error:&parseError];
    
    if (!xmlDict) {
        NSLog(@"%@", parseError.localizedDescription);
        return nil;
    } else {
        NSString *message = [[xmlDict[@"item"] objectForKey:kMessageParameter] objectForKey:@"text"];
        NSInteger boolPar = [[[xmlDict[@"item"] objectForKey:kBoolParameter] objectForKey:@"text"] integerValue];
        NSDictionary *dict = @{kMessageParameter: message,
                               kBoolParameter: @(boolPar),
                               kRequestFormat: @(XMLFormat)};
        
        return dict;
    }
}

//parse binary response into dictionary
- (NSDictionary *)retrieveDataFromBinaryDataResponse:(NSData *)data
{
    NSDictionary *binaryDict = (NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (!binaryDict) { return nil; }
    
    NSDictionary *dict = @{kMessageParameter: binaryDict[kMessageParameter],
                           kBoolParameter: binaryDict[kBoolParameter],
                           kRequestFormat: @(BinaryFormat)};
    return dict;
}


#pragma mark - Notifications

//send notification with Request object
- (void)sendRequestNotification:(Request *)request
{
    [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
        NSDictionary *dict = @{kRequestTime: [self currentTime],
                               kRequestObject: request};
        [[NSNotificationCenter defaultCenter] postNotificationName:kSendedRequestNotification object:nil userInfo:dict];
    }];
}

//send notification with response object
- (void)sendResponseNotification:(id)response
{
    NSDictionary *dict = @{kResponseTime: [self currentTime],
                           kResponseObject: response};
    [[NSNotificationCenter defaultCenter] postNotificationName:kResponseNotification object:nil userInfo:dict];
}

//send notification about current connection status
- (void)sendConnectionStatusNotification:(NSString *)status
{
    NSDictionary *dict = @{kChangesTime: [self currentTime],
                           kConnectionStatus: status};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kConnectionChangedNotification object:nil userInfo:dict];
}

//send notification with web socket error information
- (void)sendErrorNotification:(NSString *)error
{
    NSDictionary *dict = @{kErrorTime: [self currentTime],
                           kErrorInfo: error};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kErrorNotification object:nil userInfo:dict];
}

//get current time using NSDateFormatter
- (NSString *)currentTime
{
    NSDate *today = [NSDate date];
    
    NSString *currentTime = [self.dateFormatter stringFromDate:today];
    return currentTime;
}

@end
