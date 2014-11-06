//
//  TDADataManager.h
//  TestiOSDeveloperApp
//
//  Created by Vladislava Kirichenko on 11/6/14.
//  Copyright (c) 2014 Vladislava Kirichenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface TDADataManager : NSObject

@property (retain, nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

+ (TDADataManager *)sharedInstance;

@end
