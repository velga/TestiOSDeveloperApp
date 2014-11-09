//
//  Request+Utilities.m
//  TestiOSDeveloperApp
//
//  Created by Vladislava Kirichenko on 11/8/14.
//  Copyright (c) 2014 Vladislava Kirichenko. All rights reserved.
//

#import "Request+Utilities.h"
#import "TDAConstants.h"

@implementation Request (Utilities)

- (NSData *)createBinaryRepresentation
{
    NSDictionary *dict = @{kMessageParameter: self.message,
                           kBoolParameter: self.boolParameter};
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dict];
    if (data) {
        return data;
    }
    
    return nil;
}

- (NSString *)createJSONRepresentation
{
    NSDictionary *dict = @{kMessageParameter: self.message,
                           kBoolParameter: self.boolParameter};
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:0
                                                         error:&error];
    
    if (!jsonData) {
        NSLog(@"Got an error: %@", error);
        return nil;
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return [jsonString autorelease];
    }
}

- (NSString *)createXMLRepresentation
{
    NSString *xmlString = [NSString stringWithFormat:@"<item><message>%@</message><boolParam>%d</boolParam></item>", self.message, [self.boolParameter boolValue]];
    
    return xmlString;
}

@end
