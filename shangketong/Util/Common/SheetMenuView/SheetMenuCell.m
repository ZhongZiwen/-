//
//  SheetMenuCell.m
//  shangketong
//
//  Created by sungoin-zjp on 15-6-9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SheetMenuCell.h"
#import "CommonFuntion.h"

@implementation SheetMenuCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setCellDetails:(SheetMenuModel *)item{
    self.labelName.text = item.title;
    self.imgIcon.image = [UIImage imageNamed:item.icon];
}

-(void)setCellFrame{
    NSInteger vX = kScreen_Width-320;
    self.labelName.frame = [CommonFuntion setViewFrameOffset:self.labelName.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    self.imgIcon.frame = [CommonFuntion setViewFrameOffset:self.imgIcon.frame byX:vX byY:0 ByWidth:0 byHeight:0];
}

@end
