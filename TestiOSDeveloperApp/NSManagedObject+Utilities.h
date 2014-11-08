//
//  NSManagedObject+Utilities.h
//  TestiOSDeveloperApp
//
//  Created by Vladislava Kirichenko on 11/8/14.
//  Copyright (c) 2014 Vladislava Kirichenko. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Request;

@interface NSManagedObject (Utilities)

- (NSString *)createJSONRepresentation:(Request *)request;
- (NSString *)createXMLRepresentation:(Request *)request;
- (NSData *)createBinaryRepresentation:(Request *)request;

@end
