//
//  DetailSegmentCell.m
//  shangketong
//
//  Created by sungoin-zjp on 15-6-9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "DetailSegmentCell.h"
#import "CommonConstant.h"

@implementation DetailSegmentCell

- (void)awakeFromNib {
    // Initialization code
    self.contentView.backgroundColor = VIEW_BG_COLOR;
    self.btnRecord.backgroundColor = [UIColor grayColor];
    self.btnInfos.backgroundColor = [UIColor whiteColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

-(void)addClickEventForBtn{
    [self.btnRecord addTarget:self action:@selector(clickRecordOrinfos:) forControlEvents:UIControlEventTouchUpInside];
    self.btnRecord.tag = 10;
    
    [self.btnInfos addTarget:self action:@selector(clickRecordOrinfos:) forControlEvents:UIControlEventTouchUpInside];
    self.btnInfos.tag = 11;
}

///跟进记录/详细资料
-(void)clickRecordOrinfos:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSInteger tag = btn.tag;
    if (tag == 10) {
        self.btnRecord.backgroundColor = [UIColor grayColor];
        self.btnInfos.backgroundColor = [UIColor whiteColor];
    }else if (tag == 11){
        self.btnInfos.backgroundColor = [UIColor grayColor];
        self.btnRecord.backgroundColor = [UIColor whiteColor];
    }
    
    if (self.ChangeRecordOrDetailsBlock) {
        self.ChangeRecordOrDetailsBlock(tag);
    }
    
//    if (self.delegate && [self.delegate respondsToSelector:@selector(clickSegmentEvent:)]) {
//        [self.delegate clickSegmentEvent:tag];
//    }
}


-(void)setCellFrame{
    self.btnRecord.frame = CGRectMake(10, 12, (kScreen_Width-20)/2, 25);
    self.btnInfos.frame = CGRectMake(10+(kScreen_Width-20)/2, 12, (kScreen_Width-20)/2, 25);
}

@end
