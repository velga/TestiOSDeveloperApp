//
//  Request.h
//  TestiOSDeveloperApp
//
//  Created by Vladislava Kirichenko on 11/7/14.
//  Copyright (c) 2014 Vladislava Kirichenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Request : NSManagedObject

@property (nonatomic, retain) NSNumber * boolParameter;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSNumber * requestFormat;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSString * time;

@end
