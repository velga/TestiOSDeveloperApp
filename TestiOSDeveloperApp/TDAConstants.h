//
//  TDAConstants.h
//  TestiOSDeveloperApp
//
//  Created by Vladislava Kirichenko on 11/7/14.
//  Copyright (c) 2014 Vladislava Kirichenko. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum TDARequestFormat: NSInteger {
    JSONFormat = 0,
    XMLFormat,
    BinaryFormat
} RequestFormat;

typedef enum TDARequestStatus: NSInteger {
    Waiting = 0,
    Sent,
} RequestStatus;

extern NSString *const kServerURLString;

extern NSString *const kResponseNotification;

extern NSString *const kBoolParameter;
extern NSString *const kMessageParameter;
extern NSString *const kRequestFormat;
extern NSString *const kRequestStatus;
extern NSString *const kRequestTime;

extern NSString *const kResponseTime;
extern NSString *const kResponseObject;
