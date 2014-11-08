//
//  NSManagedObject+Utilities.m
//  TestiOSDeveloperApp
//
//  Created by Vladislava Kirichenko on 11/8/14.
//  Copyright (c) 2014 Vladislava Kirichenko. All rights reserved.
//

#import "NSManagedObject+Utilities.h"
#import "Request.h"
#import "TDAConstants.h"

@implementation NSManagedObject (Utilities)

- (NSData *)createBinaryRepresentation:(Request *)request
{
    NSDictionary *dict = @{kMessageParameter: request.message,
                           kBoolParameter   : request.boolParameter};
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dict];
    if (data) {
        return data;
    }
    
    return nil;
}

- (NSString *)createJSONRepresentation:(Request *)request
{
    NSDictionary *dict = @{kMessageParameter: request.message,
                           kBoolParameter   : request.boolParameter};
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if (!jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return [jsonString autorelease];
    }
    
    return nil;
}

- (NSString *)createXMLRepresentation:(Request *)request
{
    NSString *xmlString = [NSString stringWithFormat:@"<item><message>%@</message><boolParameter>%d</boolParameter></item>", request.message, [request.boolParameter boolValue]];
    
    return xmlString;
}

@end
