//
//  AreaTypeCell.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-27.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AreaTypeCell.h"

@implementation AreaTypeCell

- (void)awakeFromNib {
    // Initialization code
     [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setCellDetails:(NSDictionary *)item andIndexPath:(NSIndexPath *)indexPath{
    
    NSString *name = [item objectForKey:@"AREANAME"];
    self.labelName.text = name;
    NSString *checkboxImg = @"";
    if ([[item objectForKey:@"checked"] boolValue]) {
        checkboxImg = @"login_checkbox_filled.png";
    }else{
        checkboxImg = @"login_checkbox_empty.png";
    }
    [self.btnCheckBox setBackgroundImage:[UIImage imageNamed:checkboxImg] forState:UIControlStateNormal];
    
    self.btnCheckBox.tag = indexPath.row;
    [self.btnCheckBox addTarget:self action:@selector(checkboxAction:) forControlEvents:UIControlEventTouchUpInside];
}


-(void)checkboxAction:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (self.CheckBoxBlock) {
        self.CheckBoxBlock(btn.tag);
    }
}

@end
