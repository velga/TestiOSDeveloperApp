//
//  TDARequestSendingViewController.m
//  TestiOSDeveloperApp
//
//  Created by Vladislava Kirichenko on 11/6/14.
//  Copyright (c) 2014 Vladislava Kirichenko. All rights reserved.
//

#import "TDARequestSendingViewController.h"
#import "TDADataManager.h"
#import "TDAConstants.h"

@interface TDARequestSendingViewController ()

@property (retain, nonatomic) IBOutlet UILabel *connectionStatusLabel;
@property (retain, nonatomic) IBOutlet UITextView *infoTextView;
@property (retain, nonatomic) IBOutlet UITextField *messageTextField;
@property (retain, nonatomic) IBOutlet UISwitch *boolParameterSwitch;
@property (retain, nonatomic) IBOutlet UISegmentedControl *requestFormatControl;
@property (retain, nonatomic) IBOutlet UIButton *sendButton;

@property (retain, nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation TDARequestSendingViewController

- (void)dealloc
{
    [_connectionStatusLabel release];
    [_infoTextView release];
    [_messageTextField release];
    [_boolParameterSwitch release];
    [_requestFormatControl release];
    [_sendButton release];
    [_dateFormatter release];
    [super dealloc];
}

- (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    }
    
    return _dateFormatter;
}

- (IBAction)sendButtonPressed:(UIButton *)sender
{
    if ([self.messageTextField.text isEqualToString:@""] ||
        self.requestFormatControl.selectedSegmentIndex == UISegmentedControlNoSegment) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:@"Message field and Request Format are required"
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    } else {
        [[TDADataManager sharedInstance] addRequest:[self createRequestDictionary]];
        
        self.messageTextField.text = @"";
        self.requestFormatControl.selectedSegmentIndex = UISegmentedControlNoSegment;
    }
}

- (NSDictionary *)createRequestDictionary
{
    TDARequestFormat format = self.requestFormatControl.selectedSegmentIndex;
    
    NSDate *today = [NSDate date];
    NSString *currentTime = [self.dateFormatter stringFromDate:today];
    
    NSDictionary *dict = @{kBoolParameter: self.boolParameterSwitch.isOn? @(1) : @(0),
                           kMessageParameter: self.messageTextField.text,
                           kRequestFormat: @(format),
                           kRequestStatus: @(Waiting),
                           kRequestTime: currentTime};
    
    return dict;
}

@end
