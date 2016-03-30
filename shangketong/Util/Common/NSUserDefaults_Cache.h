//
//  NSUserDefaults_Cache.h
//  shangketong
//
//  Created by sungoin-zjp on 15-8-7.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UnReadNumberModle;

@interface NSUserDefaults_Cache : NSObject


#pragma mark - 帐号
///存储当前用户帐号信息
+(void)setUserAccountInfo:(NSDictionary *)userInfo;
///获取存储的当前用户帐号信息
+(NSDictionary *)getUserAccountInfo;

#pragma mark  登录信息
///存储当前用户信息
+(void)setUserInfo:(NSDictionary *)userInfo;
///获取存储的当前用户信息
+(NSDictionary *)getUserInfo;

#pragma mark  登录状态
///存储当前用户登录状态
+(void)setUserLoginStatus:(Boolean)status;
///获取存储的当前登录状态
+(Boolean)getUserLoginStatus;

#pragma mark 退出操作 YES(手动退出) NO(被挤掉)
///存储当前用户登录状态
+(void)setUserLogOutStatus:(NSInteger)status;
///获取存储的当前登录状态
+(NSInteger)getUserLogOutStatus;

#pragma mark - 报错消息设置
///存储消息设置
+(void)setIMMessageStatus:(Boolean)status;
///获取消息设置
+(Boolean)getIMMessageStatu;

///存储消息声音设置
+(void)setIMMessageVoiceStatus:(Boolean)status;
///获取消息声音设置
+(Boolean)getIMMessageStatuVoice;

#pragma mark - 当前选择登录的公司
///存储当前所属公司列表
+(void)setCurCompanyLogined:(NSArray *)company;
///获取当前所属公司列表
+(NSArray*)getCurCompanyLogined;


#pragma mark - 通讯录updatedAt标记
///存储通讯录请求时返回的servicetime
+(void)setAddressBookServiceTime:(NSString *)servicetime;
///获取存储的通讯录servicetime
+(NSString*)getAddressBookServiceTime;

#pragma mark - 办公功能块是否显示控制
///存储办公模块用户选择
+(void)setOAModuleOptions:(NSArray *)oaOption;
///获取办公模块用户选择
+(NSArray*)getOAModuleOptions;

#pragma mark - CRM功能块是否显示控制
///存储CRM模块用户选择
+(void)setCRMModuleOptions:(NSArray *)oaOption;
///获取CRM模块用户选择
+(NSArray*)getCRMModuleOptions;

#pragma mark - 搜索历史相关
///存储搜索历史数据
+(void)setSearchHistoryData:(NSArray *)searchHistory byHsitroyFlag:(NSString *)historyFlag;
///获取flag对应的搜索历史
+(NSArray*)getSearchHistoryDataByHsitroyFlag:(NSString *)historyFlag;


#pragma mark - 通讯录最近联系人 只保存最近5条
///存储通讯录最近联系人
+(void)setAddressBookLatelyContacts:(NSArray *)latelyContacts;
///获取通讯录最近联系人
+(NSArray*)getAddressBookLatelyContacts;

#pragma mark - 通讯录最近@联系人 只保存最近5条
///存储通讯录最近@联系人
+(void)setAddressBookLatelyAtContacts:(NSArray *)latelyAtContacts;
///获取通讯录最近@联系人
+(NSArray*)getAddressBookLatelyAtContacts;


#pragma mark - 轮询接口参数  servertime/isVictoryExist
///存储请求时间
+(void)setSKTUnReadMsgCycleServerTime:(NSString *)servertime;
+(NSString*)getSKTUnReadMsgCycleServerTime;

///存储动态请求时间
+(void)setSKTUnReadOATrendCycleServerTime:(NSString *)servertime;
+(NSString*)getSKTUnReadOATrendCycleServerTime;

///存储获取喜报标识
+(void)setSKTUnReadMsgCycleVictoryFlag:(NSInteger)victoryFlag;
+(NSInteger)getSKTUnReadMsgCycleVictoryFlag;


#pragma mark - 存储未读消息model
///存储ICON BADGE model
+(void)setApplicationIconBadgeModel:(UnReadNumberModle *)model;
+(UnReadNumberModle *)getApplicationIconBadgeModel;


#pragma mark - 存储日程检索条件
+(void)setPlanFilterValue:(NSDictionary *)filter;
+(NSDictionary *)getPlanFilterValue;


#pragma mark - 存储系统公告
+(void)setSystemInformValue:(NSDictionary *)inform;
+(NSDictionary *)getSystemInformValue;


#pragma mark - 存储最新动态
+(void)setNewTrendsInformValue:(NSDictionary *)newTrend;
+(NSDictionary *)getNewThrendsInformValue;

@end
