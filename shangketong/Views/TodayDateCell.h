//
//  TodayDateCell.h
//  shangketong
//
//  Created by 蒋 on 15/8/27.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TodayDateCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgBgView;
@property (weak, nonatomic) IBOutlet UIImageView *imgLine;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

- (void)setFrameForAllPhones;
@end
