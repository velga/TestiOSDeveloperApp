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

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleConnectionChanges:)
                                                 name:kConnectionChangedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSendedRequestNotification:)
                                                 name:kSendedRequestNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleResponseNotification:)
                                                 name:kResponseNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleErrorNotification:)
                                                 name:kErrorNotification
                                               object:nil];
}

- (void)dealloc
{
    [_connectionStatusLabel release];
    [_infoTextView release];
    [_messageTextField release];
    [_boolParameterSwitch release];
    [_requestFormatControl release];
    [_sendButton release];
    [_dateFormatter release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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


#pragma mark - Handle Notifications

- (void)handleConnectionChanges:(NSNotification *)note
{
    NSDictionary *userInfo = note.userInfo;
    
    self.connectionStatusLabel.text = userInfo[kConnectionStatus];
    
    NSString *connectioneString = [NSString stringWithFormat:@"%@: %@\n",
                                userInfo[kChangesTime], userInfo[kConnectionStatus]];
    self.infoTextView.text = [self.infoTextView.text stringByAppendingString:connectioneString];
}

- (void)handleSendedRequestNotification:(NSNotification *)note
{
    NSDictionary *userInfo = note.userInfo;
    
    NSString *sendedString = [NSString stringWithFormat:@"%@: %@\n",
                                   userInfo[kRequestTime], userInfo[kRequestObject]];
    self.infoTextView.text = [self.infoTextView.text stringByAppendingString:sendedString];
}

- (void)handleResponseNotification:(NSNotification *)note
{
    NSDictionary *userInfo = note.userInfo;
    
    NSString *responseString = [NSString stringWithFormat:@"%@: %@\n", userInfo[kResponseTime], userInfo[kResponseObject]];
    self.infoTextView.text = [self.infoTextView.text stringByAppendingString:responseString];
}

- (void)handleErrorNotification:(NSNotification *)note
{
    NSDictionary *userInfo = note.userInfo;
    
    NSString *errorString = [NSString stringWithFormat:@"%@: %@\n", userInfo[kErrorTime], userInfo[kErrorInfo]];
    self.infoTextView.text = [self.infoTextView.text stringByAppendingString:errorString];

}

@end
