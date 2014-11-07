//
//  ViewController.m
//  TestiOSDeveloperApp
//
//  Created by Vladislava Kirichenko on 11/5/14.
//  Copyright (c) 2014 Vladislava Kirichenko. All rights reserved.
//

#import "TDAViewController.h"
#import "TDARequestManager.h"

@interface TDAViewController ()

@end

@implementation TDAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //start observing changes in core data
    [[TDARequestManager sharedInstance] startObservingCoreDataChanges];
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
