//
//  ViewController.m
//  TestiOSDeveloperApp
//
//  Created by Vladislava Kirichenko on 11/5/14.
//  Copyright (c) 2014 Vladislava Kirichenko. All rights reserved.
//

#import "TDAViewController.h"
#import "TDADataManager.h"

@interface TDAViewController ()

@end

@implementation TDAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [TDADataManager sharedInstance];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
