//
//  EditItemTypeCellG.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-16.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "EditItemTypeCellG.h"
#import "CommonFunc.h"
#import "LLCenterUtility.h"
#import "EditItemModel.h"

@implementation EditItemTypeCellG

- (void)awakeFromNib {
    // Initialization code
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)selectWeekAction:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (self.SelectWeekBlock) {
        self.SelectWeekBlock(btn.tag);
    }
    
}

-(void)setCellDetail:(EditItemModel *)model{
    NSArray *week = [model.content componentsSeparatedByString:@","];
    NSString *imgSelected = @"img_select_selected.png";
    NSString *imgUnSelected = @"img_select_unselect.png";
    
    NSString *curImgStatus = @"";
    
    ///0未选择  1选中
    if ([week[0] isEqualToString:@"1"]) {
        curImgStatus = imgSelected;
    }else{
        curImgStatus = imgUnSelected;
    }
    [self.btnWeek1 setImage:[UIImage imageNamed:curImgStatus] forState:UIControlStateNormal];
    
    if ([week[1] isEqualToString:@"1"]) {
        curImgStatus = imgSelected;
    }else{
        curImgStatus = imgUnSelected;
    }
    [self.btnWeek2 setImage:[UIImage imageNamed:curImgStatus] forState:UIControlStateNormal];
    
    if ([week[2] isEqualToString:@"1"]) {
        curImgStatus = imgSelected;
    }else{
        curImgStatus = imgUnSelected;
    }
    [self.btnWeek3 setImage:[UIImage imageNamed:curImgStatus] forState:UIControlStateNormal];
    
    if ([week[3] isEqualToString:@"1"]) {
        curImgStatus = imgSelected;
    }else{
        curImgStatus = imgUnSelected;
    }
    [self.btnWeek4 setImage:[UIImage imageNamed:curImgStatus] forState:UIControlStateNormal];
    
    if ([week[4] isEqualToString:@"1"]) {
        curImgStatus = imgSelected;
    }else{
        curImgStatus = imgUnSelected;
    }
    [self.btnWeek5 setImage:[UIImage imageNamed:curImgStatus] forState:UIControlStateNormal];
    
    if ([week[5] isEqualToString:@"1"]) {
        curImgStatus = imgSelected;
    }else{
        curImgStatus = imgUnSelected;
    }
    [self.btnWeek6 setImage:[UIImage imageNamed:curImgStatus] forState:UIControlStateNormal];
    
    if ([week[6] isEqualToString:@"1"]) {
        curImgStatus = imgSelected;
    }else{
        curImgStatus = imgUnSelected;
    }
    [self.btnWeek7 setImage:[UIImage imageNamed:curImgStatus] forState:UIControlStateNormal];
}


-(void)setCellFrame{
    CGFloat xPoint = 90.0;
    CGFloat yPoint = 8.0;
    CGFloat width = (DEVICE_BOUNDS_WIDTH-110)/4;
    CGFloat height = 30.0;
    
    self.btnWeek1.frame = CGRectMake(xPoint, yPoint, width, height);
    xPoint += width;
    
    self.btnWeek2.frame = CGRectMake(xPoint, yPoint, width, height);
    xPoint += width;
    
    self.btnWeek3.frame = CGRectMake(xPoint, yPoint, width, height);
    xPoint += width;
    
    self.btnWeek4.frame = CGRectMake(xPoint, yPoint, width, height);
    
    
    xPoint = 90;
    yPoint +=35;
    
    self.btnWeek5.frame = CGRectMake(xPoint, yPoint, width, height);
    xPoint += width;
    self.btnWeek6.frame = CGRectMake(xPoint, yPoint, width, height);
    xPoint += width;
    self.btnWeek7.frame = CGRectMake(xPoint, yPoint, width, height);
    xPoint += width;
}

@end
