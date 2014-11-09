//
//  TDARequestInfoCell.m
//  TestiOSDeveloperApp
//
//  Created by Vladislava Kirichenko on 11/7/14.
//  Copyright (c) 2014 Vladislava Kirichenko. All rights reserved.
//

#import "TDARequestInfoCell.h"

@implementation TDARequestInfoCell

- (void)dealloc
{
    [_messageLabel release];
    [_timeLabel release];
    [_reqFormatLabel release];
    [_reqStatusLabel release];
    [super dealloc];
}
@end
