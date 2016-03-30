//
//  Dynamic_Data.h
//  shangketong
//
//  Created by sungoin-zjp on 15-8-7.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

///当前帐号对应的相关动态缓存
///首页工作圈，即我关注的动态
///我的动态
///我的收藏
///公开动态
#import <Foundation/Foundation.h>


/*
 存储文件路径规则 公司名称_帐号UID_动态类型.dat   只存储第一页数据
 */

@interface Dynamic_Data : NSObject


///根据登录信息 设置缓存文件的为当前路径
///公司名称_帐号UID_动态类型.dat
+(void)setDynamicCacheFilePathByUserLoginInfo;


///将更改的【我关注的动态】同步到本地文件
+(void)updateUserFocusDynamicToFile:(NSArray *)array;
///将更改的【公开动态】同步到本地文件
+(void)updateUserPublicDynamicToFile:(NSArray *)array;
///将更改的【我的收藏】同步到本地文件
+(void)updateUserFavoriteDynamicToFile:(NSArray *)array;
///将更改的【我的动态】同步到本地文件
+(void)updateUserMyDynamicToFile:(NSArray *)array;


///获取本地缓存的【我的动态】
+(void)getUserMyDynamic;
///获取本地缓存的【我收藏动态】
+(void)getUserFavoriteDynamic;
///获取本地缓存的【公开动态】
+(void)getUserPublicDynamic;
///获取本地缓存的【我关注的动态】
+(void)getUserFocusDynamic;


#pragma mark - 清除本地缓存
+(void)clearDynamicCache;


// 路径相关
+(NSString *)bundlePath:(NSString *)fileName;
+(NSString *)documentsPath:(NSString *)fileName;
+(NSString *)documentsPath;
+(NSString*)pngFileNameWithTime;
+(NSString*)h264FileNameWithTime;



@end
