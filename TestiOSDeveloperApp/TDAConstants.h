//
//  TDAConstants.h
//  TestiOSDeveloperApp
//
//  Created by Vladislava Kirichenko on 11/7/14.
//  Copyright (c) 2014 Vladislava Kirichenko. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TDARequestFormat) {
    JSONFormat = 0,
    XMLFormat,
    BinaryFormat
};

typedef NS_ENUM(NSInteger, TDARequestStatus) {
    Waiting = 0,
    Sent,
};

extern NSString *const kServerURLString;

extern NSString *const kResponseNotification;
extern NSString *const kConnectionChangedNotification;
extern NSString *const kSendedRequestNotification;
extern NSString *const kErrorNotification;

extern NSString *const kRequestObject;

extern NSString *const kBoolParameter;
extern NSString *const kMessageParameter;
extern NSString *const kRequestFormat;
extern NSString *const kRequestStatus;
extern NSString *const kRequestTime;

extern NSString *const kResponseTime;
extern NSString *const kResponseObject;

extern NSString *const kConnectionStatus;
extern NSString *const kChangesTime;

extern NSString *const kErrorTime;
extern NSString *const kErrorInfo;
