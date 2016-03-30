//
//  KnowledgeFileCellB.m
//  shangketong
//
//  Created by sungoin-zjp on 15-5-29.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "KnowledgeFileCellB.h"
#import "CommonFuntion.h"
#import "CommonConstant.h"
#import "NSUserDefaults_Cache.h"

@implementation KnowledgeFileCellB

- (void)awakeFromNib {
    // Initialization code
    self.labelName.textColor = COLOR_WORKGROUP_NAME;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

///设置frame
-(void)setCellFrame:(NSDictionary *)item{
    NSInteger vX = kScreen_Width-320;//
    self.imgIcon.frame = [CommonFuntion setViewFrameOffset:self.imgIcon.frame byX:0 byY:0 ByWidth:0 byHeight:0];
    self.imgDownloadIcon.frame = [CommonFuntion setViewFrameOffset:self.imgDownloadIcon.frame byX:0 byY:0 ByWidth:0 byHeight:0];
    
    self.labelName.frame = [CommonFuntion setViewFrameOffset:self.labelName.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    self.imgArrow.frame = [CommonFuntion setViewFrameOffset:self.imgArrow.frame byX:vX byY:0 ByWidth:0 byHeight:0];
}

///填充详情
-(void)setContentDetails:(NSDictionary *)item{
    NSString *name = @"";
    if ([item objectForKey:@"name"]) {
        name = [item safeObjectForKey:@"name"];
    }
    self.labelName.text = name;
    NSDictionary *userInfo = [NSUserDefaults_Cache getUserInfo];
    NSString *userId = [userInfo safeObjectForKey:@"id"] ;
    NSString *fileName = [NSString stringWithFormat:@"%@-%@-%@-%@",userId,[item safeObjectForKey:@"resourceId"],PATH_KNOWLEDGE_FILENAME_PREFIX,[item safeObjectForKey:@"name"]];
    
    ///判断本地是否存在此文件
    if([CommonFuntion isExistsFileInDocument:fileName]){
        self.imgDownloadIcon.hidden = NO;
    }else{
        self.imgDownloadIcon.hidden = YES;
    }
}

@end
