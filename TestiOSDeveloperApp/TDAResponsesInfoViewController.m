//
//  TDAResponsesInfoViewController.m
//  TestiOSDeveloperApp
//
//  Created by Vladislava Kirichenko on 11/6/14.
//  Copyright (c) 2014 Vladislava Kirichenko. All rights reserved.
//

#import "TDAResponsesInfoViewController.h"
#import "TDAConstants.h"

@interface TDAResponsesInfoViewController ()

@property (retain, nonatomic) IBOutlet UITextView *resievedDataTextView;

@end

@implementation TDAResponsesInfoViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleResponseNotification:)
                                                     name:kResponseNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)handleResponseNotification:(NSNotification *)note
{
    NSDictionary *userInfo = note.userInfo;
    NSString *time = userInfo[kResponseTime];
    self.resievedDataTextView.text = [self.resievedDataTextView.text stringByAppendingString:time];
}

- (void)dealloc {
    [_resievedDataTextView release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end
