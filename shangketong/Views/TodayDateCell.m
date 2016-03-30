//
//  TodayDateCell.m
//  shangketong
//
//  Created by 蒋 on 15/8/27.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "TodayDateCell.h"
#import "CommonFuntion.h"
@implementation TodayDateCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setFrameForAllPhones {
    CGFloat vX = kScreen_Width - 320;
    self.imgBgView.frame = [CommonFuntion setViewFrameOffset:self.imgBgView.frame byX:0 byY:0 ByWidth:vX / 2 byHeight:0];
    self.imgLine.frame = [CommonFuntion setViewFrameOffset:self.imgLine.frame byX:vX / 2 byY:0 ByWidth:vX / 2 byHeight:0];
    self.dateLabel.frame = [CommonFuntion setViewFrameOffset:self.dateLabel.frame byX:0 byY:0 ByWidth:vX / 2 byHeight:0];
}
@end
