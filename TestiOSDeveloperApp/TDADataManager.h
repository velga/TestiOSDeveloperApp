//
//  TDADataManager.h
//  TestiOSDeveloperApp
//
//  Created by Vladislava Kirichenko on 11/6/14.
//  Copyright (c) 2014 Vladislava Kirichenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Request;

//this class does all the work with Core Data.

@interface TDADataManager : NSObject

@property (retain, nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

+ (TDADataManager *)sharedInstance;

///Adds new Request object to data base
///@param dict NSDictionary with all data for Request object
- (void)addRequest:(NSDictionary *)dict;

///Changes Request object's status field. Use it after receiving data from server
///@param dict NSDictionary which contains:
/// kMessageParameter - contains request's message string,
/// kBoolParameter - contains request's boolean parameter,
/// kRequestFormat - contains request's format (TDARequestFormat)
- (void)changeRequestStatus:(NSDictionary *)dict;

@end
