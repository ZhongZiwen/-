//
//  MoreViewCell.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 14-12-11.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import "MoreViewCell.h"
#import "LLCenterUtility.h"
#import "CommonFunc.h"

@implementation MoreViewCell

- (void)awakeFromNib {
    // Initialization code
    [self setCellViewFrame];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setCellViewFrame
{
    if (DEVICE_IS_IPHONE6) {
        [self setViewByIphone6];
        
    }else if(DEVICE_IS_IPHONE6_PLUS)
    {
        [self setViewByIphone6];
    }
}

-(void)setViewByIphone6
{
    NSInteger vX = DEVICE_BOUNDS_WIDTH-320;// 下移
    NSInteger vY = 0;
    self.imgIcon.frame = [CommonFunc setViewFrameOffset:self.imgIcon.frame byX:0 byY:0 ByWidth:0 byHeight:0];

    self.labelTitle.frame = [CommonFunc setViewFrameOffset:self.labelTitle.frame byX:0 byY:vY ByWidth:vX byHeight:0];
    
    self.imgArrow.frame = [CommonFunc setViewFrameOffset:self.imgArrow.frame byX:vX byY:vY ByWidth:0 byHeight:0];
    
    self.imgNoticeIcon.frame = [CommonFunc setViewFrameOffset:self.imgNoticeIcon.frame byX:vX byY:vY ByWidth:0 byHeight:0];
}


@end
