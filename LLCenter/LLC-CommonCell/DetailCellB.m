//
//  DetailCellB.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-14.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "DetailCellB.h"
#import "LLCenterUtility.h"
#import "EditItemModel.h"
@implementation DetailCellB

- (void)awakeFromNib {
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    self.labelTitle.textAlignment = NSTextAlignmentLeft;

    [self setCellFrame];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCellDetail:(EditItemModel *)model{
    self.labelTitle.text = model.title;
    ///最多显示6个，多出部门用...表示
    NSString *content = model.content;
    /*
    if (content.length>6) {
        content = [NSString stringWithFormat:@"%@...",[content substringToIndex:6]];
    }
     */
    self.labelContent.text = content;
    self.labelContent.textColor = [UIColor blackColor];
}

-(void)setCellFrame{
    self.labelTitle.frame = CGRectMake(10, 15, 80, 20);
    self.labelContent.frame = CGRectMake(90, 15, 200, 20);
}


@end
