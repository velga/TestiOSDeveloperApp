//
//  TDADataManager.m
//  TestiOSDeveloperApp
//
//  Created by Vladislava Kirichenko on 11/6/14.
//  Copyright (c) 2014 Vladislava Kirichenko. All rights reserved.
//

#import "TDADataManager.h"
#import "Request.h"

@interface TDADataManager ()

@property (retain, nonatomic, readwrite) NSManagedObjectContext *managedObjectContext;
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
        [sharedInstance initCoreDataStack];
    });
    
    return sharedInstance;
}


#pragma mark - Core Data

- (NSManagedObjectContext *)managedObjectContext
{
    NSAssert(self.persistentStoreCoordinator, @"Persistent store not initialized!");
    
    static NSManagedObjectContext *moc = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        NSManagedObjectContextConcurrencyType ccType = NSMainQueueConcurrencyType;
        moc = [[[NSManagedObjectContext alloc] initWithConcurrencyType:ccType] retain];
        [moc setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    });
    
    return moc;
}

- (void)initCoreDataStack
{
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    NSAssert(modelURL, @"Failed to find model URL");
    
    NSManagedObjectModel *mom = nil;
    mom = [[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL] autorelease];
    NSAssert(modelURL, @"Failed to init model");
    
    NSPersistentStoreCoordinator *coordinator = nil;
    coordinator = [[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom] autorelease];
    NSAssert(coordinator, @"Failed to init NSPersistentStoreCoordinator");
    
    dispatch_queue_t queue = NULL;
    queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSURL *storeURL = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory]
                                                   stringByAppendingPathComponent: @"TDADataBase.sqlite"]];
        
        NSError *error = nil;
        NSPersistentStore *store = nil;
        
        store = [coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                          configuration:nil
                                                    URL:storeURL
                                                options:nil
                                                  error:&error];
        
        if (!store){
            NSLog(@"Error adding persistent store to coordinator %@\n%@", [error localizedDescription], [error userInfo]);
        }
        
//        dispatch_sync(dispatch_get_main_queue(), ^{
            self.persistentStoreCoordinator = coordinator;
            NSLog(@"Persistent store initialized");
//        });
    });
}

- (NSString *)applicationDocumentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (void)addRequest:(NSDictionary *)dict
{
//    Request *request = (Request *)[NSEntityDescription insertNewObjectForEntityForName:@"Request"
//                                                     inManagedObjectContext:self.managedObjectContext];
    
    
}

@end
