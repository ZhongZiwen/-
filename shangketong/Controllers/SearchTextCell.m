//
//  SearchTextCell.m
//  shangketong
//
//  Created by 蒋 on 15/7/10.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SearchTextCell.h"
#import "CommonFuntion.h"
@implementation SearchTextCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setFrameForAllPhone {
    NSInteger vX = kScreen_Width - 320;
    self.imgIcon.frame = [CommonFuntion setViewFrameOffset:self.imgIcon.frame byX:0 byY:0 ByWidth:0 byHeight:0];
    self.searchLabel.frame = [CommonFuntion setViewFrameOffset:self.searchLabel.frame byX:0 byY:0 ByWidth:vX byHeight:0];
}
@end
