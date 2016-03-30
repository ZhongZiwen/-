//
//  CommonCheckVersion.h
//  shangketong
//  检测版本信息
//  Created by sungoin-zjp on 15-12-18.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

//用来标记在BecomeActive方法里是否检查版本信息 0 不需要 1需要
NSInteger flagOfBecomeActive;

///以日期作为判断条件
// ---备注 NSUserDefaults   key--isNeedCheckVersion 是否需要检测版本 非强制更新选择取消时则当天不再检测
///是否有新版本
BOOL isNewVersion;


@interface CommonCheckVersion : NSObject

#pragma mark - 初始化显示信息
+(void)defaultSKTVersion;


#pragma mark - 存储版本信息
+(void)setSKTAppVersionInfo:(NSDictionary *)versionInfo;
+(NSDictionary*)getSKTAppVersionInfo;


#pragma mark - 存储检测版本日期标签
///存储检测版本日期标签
+(void)setSKTCheckVersionDateFlag:(NSString *)date_flag;
+(NSString*)getSKTCheckVersionDateFlag;


#pragma mark - setter  getter 是否显示版本信息
+(void)setShowSKTVersionView:(NSString *)show;
+(NSString *)getShowSKTVersionView;




@end
