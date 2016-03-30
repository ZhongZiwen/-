//
//  EditItemTypeCellH.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-16.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "EditItemTypeCellH.h"
#import "EditItemModel.h"
@implementation EditItemTypeCellH

- (void)awakeFromNib {
    // Initialization code
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCellDetail:(EditItemModel *)model{
    
    NSString *imgSelected = @"img_select_selected.png";
    NSString *imgUnSelected = @"img_select_unselect.png";
    ///0未选择  1选中
    NSString *curImgStatus = @"";
    if ([model.content isEqualToString:@"1"]) {
        curImgStatus = imgSelected;
    }else{
        curImgStatus = imgUnSelected;
    }
    
    [self.btnCheckBox setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    ///开通语音信箱
    if ([model.placeholder isEqualToString:@"yes"]) {
        self.btnCheckBox.enabled = YES;
    }else{
        ///未开通语音信箱
        self.btnCheckBox.enabled = NO;
        [self.btnCheckBox setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }

    [self.btnCheckBox setImage:[UIImage imageNamed:curImgStatus] forState:UIControlStateNormal];
}



- (IBAction)checkBoxAction:(id)sender {
    if (self.SelectMessageBlock) {
        self.SelectMessageBlock();
    }
}
@end
