//
//  KnowledgeDirectorieCell.m
//  shangketong
//
//  Created by sungoin-zjp on 15-5-27.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "KnowledgeDirectorieCell.h"
#import "CommonFuntion.h"
#import "CommonConstant.h"

@implementation KnowledgeDirectorieCell

- (void)awakeFromNib {
    self.labelName.textColor = COLOR_WORKGROUP_NAME;
    self.labelCount.textColor = COLOR_KNOWLEDGE_COUNT;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


///设置frame
-(void)setCellFrame{
    NSInteger vX = kScreen_Width-320;//
    self.imgIcon.frame = [CommonFuntion setViewFrameOffset:self.imgIcon.frame byX:0 byY:0 ByWidth:0 byHeight:0];
    self.labelName.frame = [CommonFuntion setViewFrameOffset:self.labelName.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    self.labelCount.frame = [CommonFuntion setViewFrameOffset:self.labelCount.frame byX:vX byY:0 ByWidth:0 byHeight:0];
    self.imgArrow.frame = [CommonFuntion setViewFrameOffset:self.imgArrow.frame byX:vX byY:0 ByWidth:0 byHeight:0];
}

///填充详情
-(void)setContentDetails:(NSDictionary *)item{
    NSString *name = @"";
    if ([item objectForKey:@"name"]) {
        name = [item safeObjectForKey:@"name"];
    }
    self.labelName.text = name;
    
    NSInteger count = 0;
    if ([item objectForKey:@"child"]) {
        count = [[item safeObjectForKey:@"child"] integerValue];
    }
    self.labelCount.text = [NSString stringWithFormat:@"%li个对象",count];
}

@end
