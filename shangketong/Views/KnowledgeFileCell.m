//
//  KnowledgeFileCell.m
//  shangketong
//
//  Created by sungoin-zjp on 15-5-27.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "KnowledgeFileCell.h"
#import "CommonFuntion.h"
#import "CommonConstant.h"
#import "NSUserDefaults_Cache.h"

@implementation KnowledgeFileCell

- (void)awakeFromNib {
    // Initialization code
    self.labelName.textColor = COLOR_WORKGROUP_NAME;
    self.labelDateAndSize.textColor = COLOR_KNOWLEDGE_DATE_SIZE;
    
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
    self.labelDateAndSize.frame = [CommonFuntion setViewFrameOffset:self.labelDateAndSize.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    self.imgArrow.frame = CGRectMake(kScreen_Width-20, 20, 8, 12);
    
    CGFloat xPoint = self.labelName.frame.origin.x;
    NSString *name = @"";
    if ([item objectForKey:@"name"]) {
        name = [item safeObjectForKey:@"name"];
    }
    if (name && ![name isEqualToString:@""]) {
        CGSize sizeName = [CommonFuntion getSizeOfContents:name Font:FONT_WORKGROUP_NAME withWidth:MAX_WIDTH_OR_HEIGHT withHeight:20];
        self.labelName.frame = CGRectMake(self.labelName.frame.origin.x, self.labelName.frame.origin.y, sizeName.width, 20);
        xPoint += sizeName.width;
    }
    
    self.imgLocked.frame = CGRectMake(xPoint+5, 12, 10, 12);
    self.imgLocked.hidden = YES;
}

///填充详情
-(void)setContentDetails:(NSDictionary *)item{
    NSString *name = @"";
    if ([item objectForKey:@"name"]) {
        name = [item safeObjectForKey:@"name"];
    }
    self.labelName.text = name;
    
    long long time = 0;
    if ([item objectForKey:@"createDate"]) {
        time = [[item safeObjectForKey:@"createDate"] longLongValue];
    }
    NSString *strDate = [CommonFuntion transDateWithTimeInterval:time withFormat:DATE_FORMAT_yyyyMMddHHmm];
    
    long long  size = 0;
    if ([item objectForKey:@"size"]) {
        size = [[item safeObjectForKey:@"size"] longLongValue];
    }
    NSString *strSize = [CommonFuntion byteConversionGBMBKB:size];
    
    self.labelDateAndSize.text = [NSString stringWithFormat:@"%@  %@",strDate,strSize];
    
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
