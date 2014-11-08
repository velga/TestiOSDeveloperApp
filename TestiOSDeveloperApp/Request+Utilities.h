//
//  Request+Utilities.h
//  TestiOSDeveloperApp
//
//  Created by Vladislava Kirichenko on 11/8/14.
//  Copyright (c) 2014 Vladislava Kirichenko. All rights reserved.
//

#import "Request.h"

@interface Request (Utilities)

- (NSString *)createJSONRepresentation;
- (NSString *)createXMLRepresentation;
- (NSData *)createBinaryRepresentation;

@end
