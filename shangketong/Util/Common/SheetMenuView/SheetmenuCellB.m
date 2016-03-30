//
//  SheetmenuCellB.m
//  shangketong
//
//  Created by sungoin-zjp on 15-6-10.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SheetmenuCellB.h"
#import "CommonFuntion.h"

@implementation SheetmenuCellB

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

-(void)setCellDetails:(SheetMenuModel *)item indexPath:(NSIndexPath *)indexPath {
    self.btnRight.hidden = YES;
    NSInteger num = [item.btnNum integerValue];
    if (num == 1) {
        self.btnLeft.frame = CGRectMake(kScreen_Width-25-15, 11, 25, 25);
    }else{
        self.btnRight.hidden = NO;
        self.btnLeft.frame = CGRectMake(kScreen_Width-40-10-25, 11, 25, 25);
        self.btnRight.frame = CGRectMake(kScreen_Width-15-25, 13, 25, 25);
    }
    
    self.labelTitle.text = item.title;
    [self.btnLeft setImage:[UIImage imageNamed:item.iconLeft] forState:UIControlStateNormal];
    [self.btnLeft setImage:[UIImage imageNamed:item.iconLeft_selected] forState:UIControlStateHighlighted];
    
    [self.btnRight setImage:[UIImage imageNamed:item.iconRight] forState:UIControlStateNormal];
    [self.btnRight setImage:[UIImage imageNamed:item.iconRight_selected] forState:UIControlStateHighlighted];
    
    
    [self.btnLeft addTarget:self action:@selector(callPhone:) forControlEvents:UIControlEventTouchUpInside];
    self.btnLeft.tag = indexPath.row;
    [self.btnRight addTarget:self action:@selector(sendMsg:) forControlEvents:UIControlEventTouchUpInside];
    self.btnRight.tag = indexPath.row;
}


///拨号事件
-(void)callPhone:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickCallPhoneEvent:)]) {
        [self.delegate clickCallPhoneEvent:btn.tag];
    }
}


///发信息事件
-(void)sendMsg:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickSendMsgEvent:)]) {
        [self.delegate clickSendMsgEvent:btn.tag];
    }
}



-(void)setCellFrame{
//    NSInteger vX = kScreen_Width-320;
//    self.labelTitle.frame = [CommonFuntion setViewFrameOffset:self.labelTitle.frame byX:0 byY:0 ByWidth:vX byHeight:0];
//    self.btnLeft.frame = [CommonFuntion setViewFrameOffset:self.btnLeft.frame byX:vX byY:0 ByWidth:0 byHeight:0];
//    self.btnRight.frame = [CommonFuntion setViewFrameOffset:self.btnRight.frame byX:vX byY:0 ByWidth:0 byHeight:0];
}


@end
