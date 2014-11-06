//
//  TDARequestManager.m
//  TestiOSDeveloperApp
//
//  Created by Vladislava Kirichenko on 11/6/14.
//  Copyright (c) 2014 Vladislava Kirichenko. All rights reserved.
//

#import "TDARequestManager.h"
#import "TDADataManager.h"

@implementation TDARequestManager

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
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleDataModelChange:)
                                                     name:NSManagedObjectContextObjectsDidChangeNotification
                                                   object:[[TDADataManager sharedInstance] managedObjectContext]];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)handleDataModelChange:(NSNotification *)note
{
    NSSet *insertedObjects = [[note userInfo] objectForKey:NSInsertedObjectsKey];
    NSLog(@"%@", insertedObjects);
}

@end
