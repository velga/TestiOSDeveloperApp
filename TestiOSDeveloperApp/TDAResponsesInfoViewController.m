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

@property (assign, nonatomic) IBOutlet UITextView *resievedDataTextView;

@end

@implementation TDAResponsesInfoViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleResponseNotification:)
                                                 name:kResponseNotification
                                               object:nil];
}

- (void)handleResponseNotification:(NSNotification *)note
{
    NSDictionary *userInfo = note.userInfo;
    NSString *time = userInfo[kResponseTime];
    id response = userInfo[kResponseObject];
    
    NSString *responseString = [NSString stringWithFormat:@"%@: %@\n", time, response];
    self.resievedDataTextView.text = [self.resievedDataTextView.text stringByAppendingString:responseString];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end
