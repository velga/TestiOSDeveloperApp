//
//  TDARequestInfoCell.h
//  TestiOSDeveloperApp
//
//  Created by Vladislava Kirichenko on 11/7/14.
//  Copyright (c) 2014 Vladislava Kirichenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDARequestInfoCell : UITableViewCell

@property (assign, nonatomic) IBOutlet UILabel *messageLabel;
@property (assign, nonatomic) IBOutlet UILabel *timeLabel;
@property (assign, nonatomic) IBOutlet UILabel *reqFormatLabel;
@property (assign, nonatomic) IBOutlet UILabel *reqStatusLabel;

@end
