//
//  SearchResultTwoCell.m
//  shangketong
//
//  Created by 蒋 on 15/7/10.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SearchResultTwoCell.h"
#import "CommonFuntion.h"
@implementation SearchResultTwoCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setFrameForAllPhone {
    NSInteger vX = kScreen_Width - 320;
    NSInteger vY = 5;
    self.imgIcon.frame = [CommonFuntion setViewFrameOffset:self.imgIcon.frame byX:0 byY:0 ByWidth:vY byHeight:vY];
    self.nameLabel.frame = [CommonFuntion setViewFrameOffset:self.nameLabel.frame byX:vY byY:0 ByWidth:vX / 2 byHeight:vY];
    self.countLabel.frame = [CommonFuntion setViewFrameOffset:self.countLabel.frame byX:vY byY:0 ByWidth:vX / 2 byHeight:vY];
}
@end
