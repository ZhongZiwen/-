//
//  EditItemTypeCellF.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-15.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "EditItemTypeCellF.h"
#import "EditItemModel.h"
#import "CommonFunc.h"
#import "LLCenterUtility.h"

@implementation EditItemTypeCellF

- (void)awakeFromNib {
    // Initialization code
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setCellDetail:(EditItemModel *)model{
    CGSize sizeTitle = [CommonFunc getSizeOfContents:model.title Font:[UIFont systemFontOfSize:15.0] withWidth:2999 withHeight:20];
    self.labelTitle.frame = CGRectMake(10, 15, sizeTitle.width, 20);
    self.labelTitle.text = model.title;
    
    self.imgArrow.frame = CGRectMake(DEVICE_BOUNDS_WIDTH-34, 12, 22, 23);
    self.btnContent.frame = CGRectMake(sizeTitle.width+10+10, 0, DEVICE_BOUNDS_WIDTH-sizeTitle.width-30-30, 50);
    
    self.btnContent.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [self.btnContent setTitleColor:COLOR_LIGHT_BLUE forState:UIControlStateNormal];
    [self.btnContent setTitle:model.content forState:UIControlStateNormal];
    
    
    [self.btnContent addTarget:self action:@selector(selectType:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)selectType:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSInteger tag = btn.tag;
    
    if (self.SelectDataTypeBlock) {
        self.SelectDataTypeBlock(tag);
    }
}

@end
