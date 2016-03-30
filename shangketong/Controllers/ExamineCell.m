//
//  ExamineCell.m
//  shangketong
//
//  Created by 蒋 on 15/9/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ExamineCell.h"
#import <UIImageView+WebCache.h>
#import "CommonFuntion.h"

@implementation ExamineCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)initWithDictionary:(NSDictionary *)dict {
    NSMutableDictionary *newDic = [NSMutableDictionary dictionaryWithCapacity:0];
    if ([dict safeObjectForKey:@"approver"]) {
        newDic = [dict objectForKey:@"approver"];
    }
    NSString *timeStr = [CommonFuntion getStringForTime:[[dict safeObjectForKey:@"createdAt"] longLongValue]];
    timeStr = [timeStr substringWithRange:NSMakeRange(5, 10)];
    _titleLabel.text = [dict safeObjectForKey:@"flowName"];
    _timeLabel.text = [NSString stringWithFormat:@"%@  %@", [newDic safeObjectForKey:@"name"], timeStr];
    [_iconImgView sd_setImageWithURL:[NSURL URLWithString:[dict safeObjectForKey:[newDic safeObjectForKey:@"icon"]]] placeholderImage:nil];
}
- (void)setFrameForAllPhones {
    NSInteger Vx = kScreen_Width - 320;
    _titleLabel.frame = [CommonFuntion setViewFrameOffset:_titleLabel.frame byX:0 byY:0 ByWidth:Vx byHeight:0];
    _timeLabel.frame = [CommonFuntion setViewFrameOffset:_timeLabel.frame byX:0 byY:0 ByWidth:Vx byHeight:0];
}
@end
