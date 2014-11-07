//
//  TDARequestInfoCell.h
//  TestiOSDeveloperApp
//
//  Created by Vladislava Kirichenko on 11/7/14.
//  Copyright (c) 2014 Vladislava Kirichenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDARequestInfoCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UILabel *messageLabel;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;
@property (retain, nonatomic) IBOutlet UILabel *reqFormatLabel;
@property (retain, nonatomic) IBOutlet UILabel *reqStatusLabel;

@end
