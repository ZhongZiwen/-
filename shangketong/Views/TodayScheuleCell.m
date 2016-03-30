//
//  TodayScheuleCell.m
//  shangketong
//
//  Created by sungoin-zjp on 15-6-5.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "TodayScheuleCell.h"
#import "CommonConstant.h"
#import "CommonFuntion.h"

@implementation TodayScheuleCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor whiteColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCellContentDetails:(NSDictionary *)item indexPath:(NSIndexPath *)indexPath{
    [self addClickEvent:indexPath.section];
}
///根据当前cell的类型 设置frame
/// type 1  11：00  框  名称
/// type 2  喜报
/// type 3 上下两行
-(void)setCellFrameByType:(NSInteger)type{
    self.imgExpIcon.hidden = NO;
    if (type == 1) {
//        NSInteger vX = kScreen_Width-320;
//        self.labelDateArea.frame = [CommonFuntion setViewFrameOffset:self.labelDateArea.frame byX:0 byY:-14 ByWidth:0 byHeight:30];
//        self.btnFlagIcon.frame = [CommonFuntion setViewFrameOffset:self.btnFlagIcon.frame byX:0 byY:6 ByWidth:0 byHeight:0];
//        self.labelName.frame = [CommonFuntion setViewFrameOffset:self.labelName.frame byX:0 byY:6 ByWidth:0 byHeight:0];
//        self.btnGoDetails.frame = [CommonFuntion setViewFrameOffset:self.btnGoDetails.frame byX:0 byY:0 ByWidth:0 byHeight:0];
//        self.imgExpIcon.frame = [CommonFuntion setViewFrameOffset:self.imgExpIcon.frame byX:vX byY:0 ByWidth:0 byHeight:0];
    }else if (type == 2){
        ///喜报
        self.imgExpIcon.hidden = YES;
        self.imgFlag.hidden = YES;
        self.labelFrom.hidden = NO;
//        NSInteger vX = kScreen_Width-320;
//        self.labelDateArea.frame = [CommonFuntion setViewFrameOffset:self.labelDateArea.frame byX:0 byY:-14 ByWidth:0 byHeight:30];
//        self.btnFlagIcon.frame = [CommonFuntion setViewFrameOffset:self.btnFlagIcon.frame byX:0 byY:0 ByWidth:0 byHeight:0];
//        self.labelName.frame = [CommonFuntion setViewFrameOffset:self.labelName.frame byX:0 byY:0 ByWidth:0 byHeight:0];
//        self.labelFrom.frame = [CommonFuntion setViewFrameOffset:self.labelFrom.frame byX:0 byY:0 ByWidth:0 byHeight:0];
//        self.btnGoDetails.frame = [CommonFuntion setViewFrameOffset:self.btnGoDetails.frame byX:0 byY:0 ByWidth:0 byHeight:0];
    }else if (type == 3){
        ///上下两行
//        NSInteger vX = kScreen_Width-320;
//        self.labelDateArea.frame = [CommonFuntion setViewFrameOffset:self.labelDateArea.frame byX:0 byY:-14 ByWidth:0 byHeight:30];
//        self.btnFlagIcon.frame = [CommonFuntion setViewFrameOffset:self.btnFlagIcon.frame byX:0 byY:0 ByWidth:0 byHeight:0];
//        self.labelName.frame = [CommonFuntion setViewFrameOffset:self.labelName.frame byX:0 byY:0 ByWidth:vX byHeight:0];
//        self.labelFrom.frame = [CommonFuntion setViewFrameOffset:self.labelFrom.frame byX:0 byY:0 ByWidth:vX byHeight:0];
//        self.btnGoDetails.frame = [CommonFuntion setViewFrameOffset:self.btnGoDetails.frame byX:0 byY:0 ByWidth:vX byHeight:0];
//        self.imgExpIcon.frame = [CommonFuntion setViewFrameOffset:self.imgExpIcon.frame byX:vX byY:0 ByWidth:0 byHeight:0];
    }
}


///添加点击事件
-(void)addClickEvent:(NSInteger)index{
    
    [self.btnGoDetails addTarget:self action:@selector(setCellBackgroupColor) forControlEvents:UIControlEventTouchDown];
    
    [self.btnGoDetails addTarget:self action:@selector(clearCellBackgroupColor) forControlEvents:UIControlEventTouchCancel];
    
    [self.btnGoDetails addTarget:self action:@selector(clearCellBackgroupColor) forControlEvents:UIControlEventTouchUpOutside];
    
    [self.btnGoDetails addTarget:self action:@selector(goDetailsViewEvent:) forControlEvents:UIControlEventTouchUpInside];
    self.btnGoDetails.tag = index;
}

///详情按钮
-(void)goDetailsViewEvent:(id)sender{
//     self.backgroundColor = [UIColor clearColor];
    UIButton *btn = (UIButton *)sender;
    NSInteger tag = btn.tag;
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickDetailsEvent:)]) {
        [self.delegate clickDetailsEvent:tag];
    }
}

-(void)setCellBackgroupColor{
//    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
    
//    self.selectedBackgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
    
}

-(void)clearCellBackgroupColor{
//    self.backgroundColor = [UIColor clearColor];
}

-(void)setCellFrame{
    NSInteger vX = kScreen_Width-320;
    self.labelDateArea.frame = [CommonFuntion setViewFrameOffset:self.labelDateArea.frame byX:0 byY:0 ByWidth:0 byHeight:0];
    self.btnFlagIcon.frame = [CommonFuntion setViewFrameOffset:self.btnFlagIcon.frame byX:0 byY:0 ByWidth:0 byHeight:0];
    self.labelName.frame = [CommonFuntion setViewFrameOffset:self.labelName.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    self.labelFrom.frame = [CommonFuntion setViewFrameOffset:self.labelFrom.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    self.btnGoDetails.frame = [CommonFuntion setViewFrameOffset:self.btnGoDetails.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    self.imgExpIcon.frame = [CommonFuntion setViewFrameOffset:self.imgExpIcon.frame byX:vX byY:0 ByWidth:0 byHeight:0];
}

@end
