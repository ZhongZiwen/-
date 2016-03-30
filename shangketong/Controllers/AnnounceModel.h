//
//  AnnounceModel.h
//  shangketong
//
//  Created by 蒋 on 15/9/30.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnnounceModel : NSObject
@property (nonatomic, strong) NSString *title; //标题
@property (nonatomic, strong) NSString *content; //公告内容
@property (nonatomic, strong) NSString *createDate; //创建时间
@property (nonatomic, strong) NSString *createUserName; //创建人名称
@property (nonatomic, strong) NSString *deptName; //部门名称
@property (nonatomic, strong) NSString *announce_ID; //公告ID
@property (nonatomic, strong) NSString *isHasRead; //是否已读
@property (nonatomic, strong) NSString *typeName; //类型名称

- (AnnounceModel *)initWithDictionary:(NSDictionary *)dict;
+ (AnnounceModel *)initWithDictionary:(NSDictionary *)dict;
@end
