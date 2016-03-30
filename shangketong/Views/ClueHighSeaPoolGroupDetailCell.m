//
//  ClueHighSeaPoolGroupDetailCell.m
//  shangketong
//
//  Created by sungoin-zjp on 15-6-3.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ClueHighSeaPoolGroupDetailCell.h"
#import "CommonConstant.h"
#import "CommonFuntion.h"

@implementation ClueHighSeaPoolGroupDetailCell

- (void)awakeFromNib {
    // Initialization code
    /// 设置字体颜色
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setCellContentDetails:(NSDictionary *)item indexPath:(NSIndexPath *)indexPath{
    
    [self.btnGet addTarget:self action:@selector(getEvent:) forControlEvents:UIControlEventTouchUpInside];
    self.btnGet.tag = indexPath.row;
    
    NSString *name = @"";
    if ([item objectForKey:@"name"]) {
        name = [item safeObjectForKey:@"name"];
    }
    self.labelName.text = name;
    
    NSString *companyName = @"";
    if ([item objectForKey:@"companyName"]) {
        companyName = [item safeObjectForKey:@"companyName"];
    }
    self.labelCompName.text = companyName;
    
    long long created = 0;
    if ([item objectForKey:@"created"]) {
        created = [[item safeObjectForKey:@"created"] longLongValue];
    }
    NSString *strDate = [CommonFuntion transDateWithTimeInterval:created withFormat:DATE_FORMAT_MMdd];
    
    
    NSInteger releaseTimes = 0;
    if ([item objectForKey:@"releaseTimes"]) {
        releaseTimes = [[item safeObjectForKey:@"releaseTimes"] integerValue];
    }
    
    NSString *releaseReason = @"";
    if ([item objectForKey:@"releaseReason"]) {
        releaseReason = [item safeObjectForKey:@"releaseReason"];
    }
    
    NSString *infos = [NSString stringWithFormat:@"%@ 创建 退回%li次",strDate,releaseTimes];
    
    if (releaseReason && ![releaseReason isEqualToString:@""]) {
        self.labelInfos.text = [NSString stringWithFormat:@"%@:%@",infos,releaseReason];
    }else{
        self.labelInfos.text = infos;
    }
}


-(void)setCellFrame{
    NSInteger vX = kScreen_Width-320;
    self.labelName.frame = [CommonFuntion setViewFrameOffset:self.labelName.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    self.labelCompName.frame = [CommonFuntion setViewFrameOffset:self.labelCompName.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    self.labelInfos.frame = [CommonFuntion setViewFrameOffset:self.labelInfos.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    
    self.btnGet.frame = [CommonFuntion setViewFrameOffset:self.btnGet.frame byX:vX byY:0 ByWidth:0 byHeight:0];
}


///点击领取事件
-(void)getEvent:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickGetEvent:)]) {
        [self.delegate clickGetEvent:btn.tag];
    }
}


@end
