//
//  SheetmenuCellC.m
//  shangketong
//
//  Created by sungoin-zjp on 15-6-16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SheetmenuCellC.h"

@implementation SheetmenuCellC

- (void)awakeFromNib {
    // Initialization code
    self.labelTitle.frame = CGRectMake(0, 0, kScreen_Width, 45);
    ///font
    ///color
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCellDetails:(SheetMenuModel *)item{
    self.labelTitle.text = item.title;
}

@end
