//
//  CommonCheckVersion.m
//  shangketong
//  
//  Created by sungoin-zjp on 15-12-18.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

///版本信息
#define SKT_APP_VERSION_INFO   @"skt_app_version_info"
///检测版本信息日期标签  每天只检测一次
#define SKT_CHECK_VERSION_DATE_FLAG   @"skt_check_version_date_flag"


#import "CommonCheckVersion.h"
#import "NSUserDefaults_Cache.h"
#import "AFNHttp.h"




///是否显示版本信息
static NSString *showVersionView;

@implementation CommonCheckVersion


/*
 private String id;
 private String name;                    // 应用名称
 private String versionName;             // 版本名
 private String versionCode;             // 版本号
 private String remark;                  // 更新内容描述
 private String size;                    // 文件大小
 private long updateTime;                // 更新时间
 private String url;                     // 下载地址url
 private int needUpdate;                 // 是否强制更新
 private int showUpdate;
 */
#pragma mark - 检测版本信息
+(void)defaultSKTVersion{
    isNewVersion = NO;
    showVersionView = @"notshow";
}


#pragma mark - 存储版本信息
+(void)setSKTAppVersionInfo:(NSDictionary *)versionInfo{
    
    NSMutableDictionary *newInfo = [[NSMutableDictionary alloc] init];
    for (NSString *key in versionInfo) {
        [newInfo setObject:[versionInfo safeObjectForKey:key] forKey:key];
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:newInfo forKey:SKT_APP_VERSION_INFO];
    [userDefaults synchronize];
}

+(NSDictionary*)getSKTAppVersionInfo{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    return  [userDefaultes dictionaryForKey:SKT_APP_VERSION_INFO];
}


#pragma mark - 存储检测版本日期标签
///存储检测版本日期标签
+(void)setSKTCheckVersionDateFlag:(NSString *)date_flag{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:date_flag forKey:SKT_CHECK_VERSION_DATE_FLAG];
    [userDefaults synchronize];
}

+(NSString*)getSKTCheckVersionDateFlag{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    return  [userDefaultes objectForKey:SKT_CHECK_VERSION_DATE_FLAG];
}


#pragma mark - setter  getter 是否显示版本信息
+(void)setShowSKTVersionView:(NSString *)show {
    showVersionView = show;
}

+(NSString *)getShowSKTVersionView{
    return showVersionView;
}

@end
