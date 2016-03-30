//
//  EditItemTypeCellE.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-14.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "EditItemTypeCellE.h"
#import "EditItemModel.h"
#import "CommonFunc.h"
#import "LLCenterUtility.h"


@implementation EditItemTypeCellE

- (void)awakeFromNib {
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    self.labelContent.textAlignment = NSTextAlignmentRight;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setCellDetail:(EditItemModel *)model{

    CGSize sizeTitle = [CommonFunc getSizeOfContents:model.title Font:[UIFont systemFontOfSize:15.0] withWidth:2999 withHeight:20];
    self.labelTitle.frame = CGRectMake(10, 15, sizeTitle.width, 20);
    self.labelTitle.text = model.title;
    
    
    self.labelContent.frame = CGRectMake(sizeTitle.width+10+10, 0, DEVICE_BOUNDS_WIDTH-sizeTitle.width-30, 50);
    self.labelContent.text = model.content;
    
}

@end
