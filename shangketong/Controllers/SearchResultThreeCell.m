//
//  SearchResultThreeCell.m
//  shangketong
//
//  Created by 蒋 on 15/7/10.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SearchResultThreeCell.h"
#import "CommonFuntion.h"

@implementation SearchResultThreeCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setFrameForAllPhone {
    NSInteger vX = kScreen_Width - 320;
    self.countLabel.frame = [CommonFuntion setViewFrameOffset:self.countLabel.frame byX:0 byY:0 ByWidth:vX byHeight:0];
}
@end
