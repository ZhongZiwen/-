//
//  SelectTimeTypeCell.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-28.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SelectTimeTypeCell.h"
#import "LLCenterUtility.h"
#import "TimeTypeModel.h"

@implementation SelectTimeTypeCell

- (void)awakeFromNib {
    // Initialization code
    [self setCellFrame];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


-(void)setCellDetails:(TimeTypeModel *)item andIndexPath:(NSIndexPath *)indexPath{
    ///星期
    NSString *checkboxImg = @"";
    if (item.checked) {
        checkboxImg = @"login_checkbox_filled.png";
    }else{
        checkboxImg = @"login_checkbox_empty.png";
    }
    [self.btnWeek setImage:[UIImage imageNamed:checkboxImg] forState:UIControlStateNormal];
    [self.btnWeek setTitle:item.sitWeek forState:UIControlStateNormal];
    
    self.btnWeek.tag = indexPath.section;
    [self.btnWeek addTarget:self action:@selector(checkboxAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    ///开始时间  结束时间
    [self.btnStartTime setTitle:item.sitPointStartTime forState:UIControlStateNormal];
    [self.btnEndTime setTitle:item.sitPointEndTime forState:UIControlStateNormal];
    
    
    self.btnStartTime.tag = indexPath.section;
    [self.btnStartTime addTarget:self action:@selector(startTimeAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.btnEndTime.tag = indexPath.section;
    [self.btnEndTime addTarget:self action:@selector(endTimeAction:) forControlEvents:UIControlEventTouchUpInside];
    
}


-(void)checkboxAction:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (self.CheckBoxBlock) {
        self.CheckBoxBlock(btn.tag);
    }
}


-(void)startTimeAction:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (self.StartTimeBlock) {
        self.StartTimeBlock(btn.tag);
    }
}

-(void)endTimeAction:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (self.EndTimeBlock) {
        self.EndTimeBlock(btn.tag);
    }
}


-(void)setCellFrame{
    self.imgStartArrow.frame = CGRectMake(DEVICE_BOUNDS_WIDTH-30, 12, 12, 20);
    self.imgEndArrow.frame = CGRectMake(DEVICE_BOUNDS_WIDTH-30, 50, 12, 20);
    
    self.btnStartTime.frame = CGRectMake(160, 7, DEVICE_BOUNDS_WIDTH-30-170, 20);
    self.btnEndTime.frame = CGRectMake(160, 45, DEVICE_BOUNDS_WIDTH-30-170, 20);
}

@end
