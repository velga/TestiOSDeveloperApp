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

@interface TDARequestManager () <SRWebSocketDelegate>

@property (retain, nonatomic) NSOperationQueue *operationQueue;

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
        [sharedInstance startObservingReachability];
        [sharedInstance connectWebSocet];
    });
    
    return sharedInstance;
}

- (NSOperationQueue *)operationQueue
{
    if (!_operationQueue) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.name = @"requestsSendingQueue";
    }
    
    return _operationQueue;
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
    if(curReach.currentReachabilityStatus == NotReachable) {
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
    [_webSocket release];
    
    NSURL *url = [NSURL URLWithString:kServerURLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    _webSocket = [[SRWebSocket alloc] initWithURLRequest:request];
    _webSocket.delegate = self;
    
    [_webSocket open];
    NSLog(@"Opening connection");
}

- (void)handleDataModelChange:(NSNotification *)note
{
    NSSet *insertedObjects = [[note userInfo] objectForKey:NSInsertedObjectsKey];
    
    [insertedObjects enumerateObjectsUsingBlock:^(Request *request, BOOL *stop) {
        __block TDARequestManager *blockSelf = self;
        if (!blockSelf) { return; }
        [self.operationQueue addOperationWithBlock:^{
            [blockSelf sendDataToServer:request];
        }];
    }];
}


#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    NSLog(@"Websocket Connected");
    [self.operationQueue setSuspended:NO];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    NSLog(@"Websocket Failed With Error %@", error);
    if (_hasInternetConnection) {
        [self connectWebSocet];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;
{
    NSLog(@"Received \"%@\"", message);
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"WebSocket closed");
    [self connectWebSocet];
}

- (void)sendDataToServer:(Request *)request
{
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

@end
