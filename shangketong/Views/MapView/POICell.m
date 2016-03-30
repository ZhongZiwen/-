//
//  POICell.m
//  DemoMapViewPOI
//
//  Created by sungoin-zjp on 15-5-7.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#define kScreen_Height [UIScreen mainScreen].bounds.size.height
#define kScreen_Width [UIScreen mainScreen].bounds.size.width

#import "POICell.h"
#import "CommonFuntion.h"
@implementation POICell

- (void)awakeFromNib {
    // Initialization code
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


-(void)setCellFrame{
    NSInteger vX = kScreen_Width-320;//
    self.imgIcon.frame = [CommonFuntion setViewFrameOffset:self.imgIcon.frame byX:0 byY:0 ByWidth:0 byHeight:0];
    self.lableName.frame = [CommonFuntion setViewFrameOffset:self.lableName.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    self.lableSteet.frame = [CommonFuntion setViewFrameOffset:self.lableSteet.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    self.imgSelected.frame = [CommonFuntion setViewFrameOffset:self.imgSelected.frame byX:vX byY:0 ByWidth:0 byHeight:0];
}




@end
