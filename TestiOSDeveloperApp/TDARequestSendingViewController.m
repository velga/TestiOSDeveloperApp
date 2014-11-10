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

@property (assign, nonatomic) IBOutlet UILabel *connectionStatusLabel;
@property (assign, nonatomic) IBOutlet UITextView *infoTextView;
@property (assign, nonatomic) IBOutlet UITextField *messageTextField;
@property (assign, nonatomic) IBOutlet UISwitch *boolParameterSwitch;
@property (assign, nonatomic) IBOutlet UISegmentedControl *requestFormatControl;
@property (assign, nonatomic) IBOutlet UIButton *sendButton;

@property (retain, nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation TDARequestSendingViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    //start receiving notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleConnectionChanges:)
                                                 name:kConnectionChangedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSentRequestNotification:)
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
    [self.view endEditing:YES];
    
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
        //here we add entered user info into new Request object
        [[TDADataManager sharedInstance] addRequest:[self createRequestDictionary]];
        
        self.messageTextField.text = @"";
        self.requestFormatControl.selectedSegmentIndex = UISegmentedControlNoSegment;
    }
}

///Creates dictionary with user data to add new Request object to data base
///@return NSDictionary with full user information needed to create new Request object
- (NSDictionary *)createRequestDictionary
{
    TDARequestFormat format = (TDARequestFormat) self.requestFormatControl.selectedSegmentIndex;
    
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

- (void)handleSentRequestNotification:(NSNotification *)note
{
    NSDictionary *userInfo = note.userInfo;
    
    NSString *sentString = [NSString stringWithFormat:@"%@: %@\n",
                                   userInfo[kRequestTime], userInfo[kRequestObject]];
    self.infoTextView.text = [self.infoTextView.text stringByAppendingString:sentString];
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
