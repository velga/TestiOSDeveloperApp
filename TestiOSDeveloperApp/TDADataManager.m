//
//  TDADataManager.m
//  TestiOSDeveloperApp
//
//  Created by Vladislava Kirichenko on 11/6/14.
//  Copyright (c) 2014 Vladislava Kirichenko. All rights reserved.
//

#import "TDADataManager.h"
#import "Request.h"
#import "TDAConstants.h"

@interface TDADataManager ()

@property (retain, nonatomic, readwrite) NSManagedObjectContext *managedObjectContext;
@property (retain, nonatomic, readwrite) NSManagedObjectModel *managedObjectModel;
@property (retain, nonatomic, readwrite) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation TDADataManager

#pragma mark - Shared Instance

+ (TDADataManager *)sharedInstance
{
    static dispatch_once_t onceToken = 0;
    static TDADataManager *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[TDADataManager alloc] init] retain];
    });
    
    return sharedInstance;
}


#pragma mark - Core Data

- (NSManagedObjectContext *)managedObjectContext
{
    if (!_managedObjectContext) {
        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
        
        if (coordinator) {
            _managedObjectContext = [[NSManagedObjectContext alloc] init];
            [_managedObjectContext setPersistentStoreCoordinator:coordinator];
        }
    }
    
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (!_managedObjectModel) {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
        NSAssert(modelURL, @"Failed to find model URL");
        
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        NSAssert(_managedObjectModel, @"Failed to init model");
    }
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (!_persistentStoreCoordinator) {
        NSURL *applicationDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        NSURL *storeURL = [applicationDocumentsDirectory URLByAppendingPathComponent:@"TDADataBase.sqlite"];
        
        NSError *error = nil;
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        NSAssert(_persistentStoreCoordinator, @"Failed to init NSPersistentStoreCoordinator");
        
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
            NSLog(@"Error adding persistent store to coordinator %@\n%@", [error localizedDescription], [error userInfo]);
        }
    }
    
    NSLog(@"Persistent store initialized");
    return _persistentStoreCoordinator;
}

- (void)addRequest:(NSDictionary *)dict
{
    Request *request = (Request *)[NSEntityDescription insertNewObjectForEntityForName:@"Request"
                                                                inManagedObjectContext:self.managedObjectContext];
    
    [request setBoolParameter:dict[kBoolParameter]];
    [request setMessage:dict[kMessageParameter]];
    [request setRequestFormat:dict[kRequestFormat]];
    [request setTime:dict[kRequestTime]];
    
    NSError *error;
    if (![[self managedObjectContext] save:&error]) {
        NSLog(@"Error saving the entity");
    }
}

- (void)changeRequestStatus:(NSDictionary *)dict
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Request" inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *fRequest = [[[NSFetchRequest alloc] init] autorelease];
    [fRequest setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(message LIKE[c] %@) AND (boolParameter == %@) AND (requestFormat == %@)",
                              dict[kMessageParameter], dict[kBoolParameter], dict[kRequestFormat]];
    [fRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *array = [self.managedObjectContext executeFetchRequest:fRequest error:&error];
    if (!array) {
        return;
    } else {
        Request *request = array.firstObject;
        [request setStatus:@(Sent)];
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Unable to save managed object context.");
            NSLog(@"%@, %@", error, error.localizedDescription);
        }
    }
}

- (void)dealloc {
    [_managedObjectContext release];
    [_managedObjectModel release];
    [_persistentStoreCoordinator release];
    [super dealloc];
}

@end
