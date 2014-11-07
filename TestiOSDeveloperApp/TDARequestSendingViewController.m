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

@end

@implementation TDARequestSendingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_connectionStatusLabel release];
    [_infoTextView release];
    [_messageTextField release];
    [_boolParameterSwitch release];
    [_requestFormatControl release];
    [_sendButton release];
    [super dealloc];
}

- (IBAction)sendButtonPressed:(UIButton *)sender
{
    if ([self.messageTextField.text isEqualToString:@""] ||
        self.requestFormatControl.selectedSegmentIndex == UISegmentedControlNoSegment) {
        NSString *msg = @"Message field and Request Format are required";
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:msg
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil] autorelease];
        [alert show];
        return;
    }
    
    [[TDADataManager sharedInstance] addRequest:[self createRequestDictionary]];
    
    self.messageTextField.text = @"";
    self.requestFormatControl.selectedSegmentIndex = UISegmentedControlNoSegment;
}

- (NSDictionary *)createRequestDictionary
{
    RequestFormat format = self.requestFormatControl.selectedSegmentIndex;
    
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    
    NSString *currentTime = [dateFormatter stringFromDate:today];
    [dateFormatter release];
    
    NSDictionary *dict = @{kBoolParameter   : self.boolParameterSwitch.isOn? @(1) : @(0),
                           kMessageParameter: self.messageTextField.text,
                           kRequestFormat   : @(format),
                           kRequestStatus   : @(NotSynchronized),
                           kRequestTime     : currentTime};
    
    return dict;
}

@end
