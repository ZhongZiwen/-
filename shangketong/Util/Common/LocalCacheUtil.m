//
//  LocalCacheUtil.m
//  
//
//  Created by sungoin-zjp on 16/3/8.
//
//

#import "LocalCacheUtil.h"
#import "NSUserDefaults_Cache.h"
#import "LLC_NSUserDefaults_Cache.h"
#import "Dynamic_Data.h"

@implementation LocalCacheUtil

///退出登录完成 数据处理
+(void)clearCacheBylogoutComplete:(NSInteger) logoutStaus{
    
    [appDelegateAccessor removeTimer];
    [appDelegateAccessor removeHeartTimer];
    [appDelegateAccessor deleteWebSocket];
    
    // 删除FMDB
    [[FMDBManagement sharedFMDBManager] deleteFMDB];
    // 删除通讯录请求时间
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAddressBookServerTime];
    
    ///登录状态
    [NSUserDefaults_Cache setUserLoginStatus:false];
    [NSUserDefaults_Cache setUserLogOutStatus:logoutStaus];
    
    ///清空密码
    ///缓存帐号信息
    NSDictionary *account = [NSUserDefaults_Cache getUserAccountInfo];
    NSString *accountName = [account safeObjectForKey:@"accountName"];
    NSString *password = [account safeObjectForKey:@"password"];
    NSDictionary *accountInfo = [NSDictionary dictionaryWithObjectsAndKeys:accountName,@"accountName", password,@"password", nil];
    [NSUserDefaults_Cache setUserAccountInfo:accountInfo];
    
    ///清除联络中心账号
    [LLC_NSUserDefaults_Cache  saveLLCAccountInfo:nil];
    
    ///清空所属公司列表
    [NSUserDefaults_Cache setCurCompanyLogined:nil];
    
    ///喜报参数
    [NSUserDefaults_Cache setSKTUnReadMsgCycleVictoryFlag:-1];
    [NSUserDefaults_Cache setSKTUnReadMsgCycleServerTime:@""];
    ///清空用户信息
    //    [NSUserDefaults_Cache setUserInfo:nil];
    ///清除动态相关缓存
    [Dynamic_Data clearDynamicCache];
    
    ///清除未读消息数缓存
    [NSUserDefaults_Cache setApplicationIconBadgeModel:nil];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    ///清除日程检索条件缓存
    [NSUserDefaults_Cache setPlanFilterValue:nil];
}

@end
