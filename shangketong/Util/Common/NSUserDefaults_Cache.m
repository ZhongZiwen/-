//
//  NSUserDefaults_Cache.m
//  shangketong
//
//  Created by sungoin-zjp on 15-8-7.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#define kUserAccountInfo   @"user_account_info"
#define kUserInfo   @"user_info"
#define kUserLoginStatus   @"user_login_status"
#define kUserLoginCompany   @"user_login_company"
#define kUserFunctionCodes @"user_functionCodes"
#define KUserLogOutStatus  @"user_logOut_status"

#define kIMMessageSwitch @"im_message_switch"
#define kIMMessageVoice  @"im_message_voice"

///办公页面
#define kOAModuleOptions   @"user_oa_module_option"
///CRM页面
#define kCRMModuleOptions   @"user_crm_module_option"

///标记搜索历史 _后添加flag
#define kSearchHistory   @"search_history_"


///通讯录请求servicetime
#define kAddressBookServiceTime   @"addressbook_servicetime"
///通讯录-最近联系人
#define kAddressBookLatelyContacts   @"addressbook_latelycontact"
///通讯录-最近@的联系人
#define kAddressBookLatelyAtContacts   @"addressbook_latelyatcontact"

///轮询接口两个参数缓存标识
#define SKT_UNREAD_MSG_CYCLE_SERVERTIME   @"skt_unread_msg_cycle_servertime"
#define SKT_UNREAD_MSG_CYCLE_IS_VICTORY_EXIST   @"skt_unread_msg_cycle_is_victory_exist"
///动态时间戳
#define SKT_UNREAD_OA_TREND_CYCLE_SERVERTIME   @"skt_unread_oa_trend_cycle_servertime"

///系统公告缓存标识
#define SKT_SYSTEM_MSG_CYCLE_FLAG   @"skt_system_msg_cycle_flag"

///最新动态缓存标识
#define SKT_OA_NEW_TRENDS_FLAG   @"skt_oa_new_trends_flag"

///APP ICON BADGE
#define kApplicationIconBadgeModel  @"skt_application_icon_badge_model"

///日程检索条件（显示任务  显示已完成任务  显示当天喜报）
#define kOAPlanFilter  @"skt_oa_plan_filter"

#import "NSUserDefaults_Cache.h"
#import "CommonConstant.h"

@implementation NSUserDefaults_Cache


#pragma mark - 获取key前缀 公司名_id
+(NSString *)getKeyPreStr{
    NSDictionary *userInfo = [NSUserDefaults_Cache getUserInfo];
    NSString *companyName = [userInfo safeObjectForKey:@"companyName"];
    NSString *userId = [userInfo safeObjectForKey:@"id"] ;
    return  [NSString stringWithFormat:@"%@_%@",companyName,userId];
}

#pragma mark - 帐号信息
///存储当前用户帐号信息
+(void)setUserAccountInfo:(NSDictionary *)userInfo{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:userInfo forKey:kUserAccountInfo];
    [userDefaults synchronize];
    
}

///获取存储的当前用户帐号信息
+(NSDictionary *)getUserAccountInfo{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    return  [userDefaultes dictionaryForKey:kUserAccountInfo];
}

#pragma mark  登录信息
///存储当前用户信息
+(void)setUserInfo:(NSDictionary *)userInfo{
    if (userInfo) {
        NSMutableDictionary *infos = [[NSMutableDictionary alloc] init];
        for(NSString *infoKey in userInfo) {
            [infos setObject:[userInfo safeObjectForKey:infoKey] forKey:infoKey];
        }
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:infos forKey:kUserInfo];
        [userDefaults synchronize];
    }
}

///获取存储的当前用户信息
+(NSDictionary *)getUserInfo{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    return  [userDefaultes dictionaryForKey:kUserInfo];
}


#pragma mark - 切换公司列表
///存储当前所属公司列表
+(void)setCurCompanyLogined:(NSArray *)company{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:company forKey:kUserLoginCompany];
    [userDefaults synchronize];
}

///获取当前所属公司列表
+(NSArray*)getCurCompanyLogined{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    return  [userDefaultes arrayForKey:kUserLoginCompany];
}

#pragma mark  登录状态
///存储当前用户登录状态
+(void)setUserLoginStatus:(Boolean)status{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:status forKey:kUserLoginStatus];
    [userDefaults synchronize];
}

///获取存储的当前登录状态
+(Boolean)getUserLoginStatus{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    return  [userDefaultes boolForKey:kUserLoginStatus];
}


#pragma mark - 报错消息设置
///存储消息设置
+(void)setIMMessageStatus:(Boolean)status{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:status forKey:kIMMessageSwitch];
    [userDefaults synchronize];
    
}
///获取消息设置
+(Boolean)getIMMessageStatu{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    return  [userDefaultes boolForKey:kIMMessageSwitch];
}

///存储消息声音设置
+(void)setIMMessageVoiceStatus:(Boolean)status{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:status forKey:kIMMessageVoice];
    [userDefaults synchronize];
}
///获取消息声音设置
+(Boolean)getIMMessageStatuVoice{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    return  [userDefaultes boolForKey:kIMMessageVoice];
}


#pragma mark 退出操作 1(手动退出) 2(被挤掉)
///存储当前用户登录状态
+(void)setUserLogOutStatus:(NSInteger)status {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(status) forKey:KUserLogOutStatus];
    [userDefaults synchronize];
}
///获取存储的当前登录状态
+(NSInteger)getUserLogOutStatus {
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    return  [[userDefaultes objectForKey:KUserLogOutStatus] integerValue];
}

#pragma mark - 通讯录updatedAt标记
///存储通讯录请求时返回的servicetime
+(void)setAddressBookServiceTime:(NSString *)servicetime{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:servicetime forKey:[NSString stringWithFormat:@"%@_%@",[self getKeyPreStr],kAddressBookServiceTime]];
    [userDefaults synchronize];
}


///获取存储的通讯录servicetime
+(NSString*)getAddressBookServiceTime{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    return  [userDefaultes objectForKey:[NSString stringWithFormat:@"%@_%@",[self getKeyPreStr],kAddressBookServiceTime]];
}



#pragma mark - 办公功能块是否显示控制
///存储办公模块用户选择
+(void)setOAModuleOptions:(NSArray *)oaOption{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:oaOption forKey:[NSString stringWithFormat:@"%@_%@",[self getKeyPreStr],kOAModuleOptions]];
    [userDefaults synchronize];
}
///获取办公模块用户选择
+(NSArray*)getOAModuleOptions{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    return  [userDefaultes arrayForKey:[NSString stringWithFormat:@"%@_%@",[self getKeyPreStr],kOAModuleOptions]];
}


#pragma mark - CRM功能块是否显示控制
///存储CRM模块用户选择
+(void)setCRMModuleOptions:(NSArray *)oaOption{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:oaOption forKey:[NSString stringWithFormat:@"%@_%@",[self getKeyPreStr],kCRMModuleOptions]];
    [userDefaults synchronize];
}
///获取CRM模块用户选择
+(NSArray*)getCRMModuleOptions{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    return  [userDefaultes arrayForKey:[NSString stringWithFormat:@"%@_%@",[self getKeyPreStr],kCRMModuleOptions]];
}


#pragma mark - 搜索历史相关

///存储搜索历史数据
+(void)setSearchHistoryData:(NSArray *)searchHistory byHsitroyFlag:(NSString *)historyFlag{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:searchHistory forKey:[NSString stringWithFormat:@"%@%@",[NSString stringWithFormat:@"%@_%@",[self getKeyPreStr],kSearchHistory],historyFlag]];
    [userDefaults synchronize];
}
///获取flag对应的搜索历史
+(NSArray*)getSearchHistoryDataByHsitroyFlag:(NSString *)historyFlag{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    return  [userDefaultes arrayForKey:[NSString stringWithFormat:@"%@%@",[NSString stringWithFormat:@"%@_%@",[self getKeyPreStr],kSearchHistory],historyFlag]];
}


#pragma mark - 通讯录最近联系人 只保存最近5条

///存储通讯录最近联系人
+(void)setAddressBookLatelyContacts:(NSArray *)latelyContacts {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:latelyContacts forKey:[NSString stringWithFormat:@"%@_%@",[self getKeyPreStr],kAddressBookLatelyContacts]];
    [userDefaults synchronize];
}
///获取通讯录最近联系人
+(NSArray*)getAddressBookLatelyContacts{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    return  [userDefaultes arrayForKey:[NSString stringWithFormat:@"%@_%@",[self getKeyPreStr],kAddressBookLatelyContacts]];
}

#pragma mark - 通讯录最近@的联系人 只保存最近5条

///存储通讯录最近@联系人
+(void)setAddressBookLatelyAtContacts:(NSArray *)latelyAtContacts {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:latelyAtContacts forKey:[NSString stringWithFormat:@"%@_%@",[self getKeyPreStr],kAddressBookLatelyAtContacts]];
    [userDefaults synchronize];
}
///获取通讯录最近@联系人
+(NSArray*)getAddressBookLatelyAtContacts{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    return  [userDefaultes arrayForKey:[NSString stringWithFormat:@"%@_%@",[self getKeyPreStr],kAddressBookLatelyAtContacts]];
}



#pragma mark - 轮询接口参数  servertime/isVictoryExist
///存储请求时间
+(void)setSKTUnReadMsgCycleServerTime:(NSString *)servertime{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:servertime forKey:SKT_UNREAD_MSG_CYCLE_SERVERTIME];
    [userDefaults synchronize];
}
+(NSString*)getSKTUnReadMsgCycleServerTime{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    return  [userDefaultes objectForKey:SKT_UNREAD_MSG_CYCLE_SERVERTIME];
}

///存储动态请求时间
+(void)setSKTUnReadOATrendCycleServerTime:(NSString *)servertime{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:servertime forKey:SKT_UNREAD_OA_TREND_CYCLE_SERVERTIME];
    [userDefaults synchronize];
}
+(NSString*)getSKTUnReadOATrendCycleServerTime{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    return  [userDefaultes objectForKey:SKT_UNREAD_OA_TREND_CYCLE_SERVERTIME];
}


///存储获取喜报标识
+(void)setSKTUnReadMsgCycleVictoryFlag:(NSInteger)victoryFlag{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:victoryFlag forKey:SKT_UNREAD_MSG_CYCLE_IS_VICTORY_EXIST];
    [userDefaults synchronize];
}
+(NSInteger)getSKTUnReadMsgCycleVictoryFlag{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    if([userDefaultes objectForKey:SKT_UNREAD_MSG_CYCLE_IS_VICTORY_EXIST]){
        return  [userDefaultes integerForKey:SKT_UNREAD_MSG_CYCLE_IS_VICTORY_EXIST];
    }
    return -1;
}


#pragma mark - 存储ICON BADGE
///存储ICON BADGE
+(void)setApplicationIconBadgeModel:(UnReadNumberModle *)model{
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:model];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:data forKey:kApplicationIconBadgeModel];
    [userDefaults synchronize];
}

+(UnReadNumberModle *)getApplicationIconBadgeModel{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSData *data = [userDefaultes objectForKey:kApplicationIconBadgeModel];
    if(data){
        UnReadNumberModle *model = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        return  model;
    }
    return nil;
}


#pragma mark - 存储日程检索条件
+(void)setPlanFilterValue:(NSDictionary *)filter{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:filter forKey:kOAPlanFilter];
    [userDefaults synchronize];
}

+(NSDictionary *)getPlanFilterValue{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    return  [userDefaultes objectForKey:kOAPlanFilter];
}


#pragma mark - 存储系统公告
+(void)setSystemInformValue:(NSDictionary *)inform{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:inform forKey:SKT_SYSTEM_MSG_CYCLE_FLAG];
    [userDefaults synchronize];
}

+(NSDictionary *)getSystemInformValue{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    return  [userDefaultes objectForKey:SKT_SYSTEM_MSG_CYCLE_FLAG];
}


#pragma mark - 存储最新动态
+(void)setNewTrendsInformValue:(NSDictionary *)newTrend{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:newTrend forKey:SKT_OA_NEW_TRENDS_FLAG];
    [userDefaults synchronize];
}

+(NSDictionary *)getNewThrendsInformValue{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    return  [userDefaultes objectForKey:SKT_OA_NEW_TRENDS_FLAG];
}

/*
 
 {
 company = "\U65e0\U7ebf\U901a";
 icon = "/resource/img.do?u=LzI5NC8yMDE1LTA4LTA1LzE0Mzg3Nzc0NTc5MDUub3RoZXI=";
 id = 377;
 name = "\U5c0f\U9648\U78ca";
 serverTime = 1438949612542;
 }
 
 
 */


@end
