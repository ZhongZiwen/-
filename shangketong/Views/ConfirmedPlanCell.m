//
//  ConfirmedPlanCell.m
//  shangketong
//
//  Created by 蒋 on 15/8/14.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ConfirmedPlanCell.h"
#import "CommonFuntion.h"
@implementation ConfirmedPlanCell

- (void)awakeFromNib {
    // Initialization code
    
    _confirmeBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_confirmeBtn.layer setMasksToBounds:YES];
    [_confirmeBtn.layer setCornerRadius:6];
//    [_confirmeBtn.layer setBorderWidth:1];
//    _confirmeBtn.layer.borderColor = [UIColor colorWithHexString:@"cbcdcd"].CGColor;
    [_confirmeBtn setBackgroundImage:[UIImage imageWithColor:COMMEN_LABEL_COROL] forState:UIControlStateNormal];
    [_confirmeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setCellValue:(NSDictionary *)dict {
    NSString *planName = @"";
    NSString *startDate = @"";
    NSString *endDate = @"";
    NSString *contactName = @"";
    NSString *timeStartStr = @""; //截取开始时间
    NSString *timeEndStr = @"";  //截取结束时间
    NSInteger isAllDay; //0全天   1非全天
    /*
     {
     colorType =                 {
     };
     createName = 516119693;
     createdAt = 1439516805168;
     createdBy = 378;
     description = "<null>";
     endDate = 1439521200000;
     id = 321;
     isAllDay = 1;
     isPrivate = 1;
     isRecur = 1;
     name = "\U5f85\U786e\U8ba41";
     reminder = "-1";
     startDate = 1439519400000;
     updatedAt = 1439516805168;
     updatedBy = 378;
     }
     */
    
    if (dict && [dict objectForKey:@"name"]) {
        planName = [dict safeObjectForKey:@"name"];
    }
    _titleLabel.text = planName;
    
    if (dict && [dict objectForKey:@"startDate"]) {
        startDate = [CommonFuntion getStringForTime:[[dict safeObjectForKey:@"startDate"] longLongValue]];
        timeStartStr = [startDate substringToIndex:10];
    }
    if (dict && [dict objectForKey:@"endDate"]) {
        endDate = [CommonFuntion getStringForTime:[[dict safeObjectForKey:@"endDate"] longLongValue]];
        timeEndStr = [endDate substringToIndex:10];
    }
    if (dict && [dict objectForKey:@"isAllDay"]) {
        isAllDay = [[dict safeObjectForKey:@"isAllDay"] integerValue];
    }
    if ([timeStartStr isEqualToString:timeEndStr]) {
        if (isAllDay == 0) {
            startDate = [NSString
                         stringWithFormat:@"%@ %@", timeStartStr, @"00:00"];
            endDate = [NSString stringWithFormat:@"%@ %@", timeEndStr, @"23:59"];
        } else {
            endDate = [endDate substringWithRange:NSMakeRange(11, 5)];
        }
    } else {
        if (isAllDay == 0) {
            startDate = [NSString stringWithFormat:@"%@ %@", timeStartStr, @"00:00"];
            endDate = [NSString stringWithFormat:@"%@ %@", timeEndStr, @"23:59"];
        } else {
            
        }
    }
    _timeLabel.text = [NSString stringWithFormat:@"%@ - %@", startDate, endDate];
    if (dict && [dict objectForKey:@"createName"]) {
        contactName = [dict safeObjectForKey:@"createName"];
    }
    _contactLable.text = [NSString stringWithFormat:@"受邀人:%@", contactName];
    
    //scheduleId日程id,staffId接受日程用户id
    if (dict && [dict objectForKey:@"id"]) {
        _planID = [[dict safeObjectForKey:@"id"] longLongValue];
    }
    [_confirmeBtn addTarget:self action:@selector(confirmeOnePlan) forControlEvents:UIControlEventTouchUpInside];
}
- (void)confirmeOnePlan {
    NSLog(@"获取日程ID%lld", _planID);
    if (_backOnePlanIDBlock) {
        _backOnePlanIDBlock(_planID);
    }
}
#pragma mark -  适配
- (void)setFrameForAllPhone {
    CGFloat vX = kScreen_Width - 320;
    _titleLabel.frame = [CommonFuntion setViewFrameOffset:_titleLabel.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    _timeLabel.frame = [CommonFuntion setViewFrameOffset:_timeLabel.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    _confirmeBtn.frame = [CommonFuntion setViewFrameOffset:_confirmeBtn.frame byX:vX - 5 byY:0 ByWidth:0 byHeight:0];
    _contactLable.frame = [CommonFuntion setViewFrameOffset:_contactLable.frame byX:0 byY:0 ByWidth:vX byHeight:0];
}
@end
