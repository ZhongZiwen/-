//
//  CommonRequstFuntion.h
//  shangketong
//  公用请求类
//  Created by sungoin-zjp on 15-5-27.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonRequstFuntion : NSObject

///根据目录id请求其对应的文件信息
-(NSDictionary *)getKnowledgeFileByDirId:(NSString *)dirId;
///登录事件
+(NSDictionary *)loginEvent;

#pragma mark - 获取部门或分组数据
+(void)getDepartmentsOrGroupDataFromService:(NSString *)dataType;


#pragma mark - 举报功能
+(void)reportFun;

@end
