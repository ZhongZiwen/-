//
//  ConfirmedPlanCell.h
//  shangketong
//
//  Created by 蒋 on 15/8/14.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfirmedPlanCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *contactLable;
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@property (weak, nonatomic) IBOutlet UIButton *confirmeBtn;

@property (nonatomic, assign) long long planID;
@property (nonatomic, copy) void(^backOnePlanIDBlock)(long long scheduleId);
- (void)setCellValue:(NSDictionary *)dict;
- (void)setFrameForAllPhone;
@end
