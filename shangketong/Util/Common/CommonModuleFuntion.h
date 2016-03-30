//
//  CommonModuleFuntion.h
//  shangketong
//  项目模块公用方法类
//  Created by sungoin-zjp on 15-6-24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AddressBook;
@class FMDB_SKT_CACHE;

@interface CommonModuleFuntion : NSObject

///市场活动 - statusNames 获取状态名称
+(NSString *)getCampaignStatusName:(NSInteger)status;

///公海池 - statusNames 获取状态名称
+(NSString *)getHighSeaStatusName:(NSInteger)status;

///销售线索 - statusNames 获取状态名称
+(NSString *)getSaleLeadStatusName:(NSInteger)status;

///根据 type system action 获取信息
+(NSString *)getActionsNameByType:(NSInteger)type andSystem:(NSInteger)system andAction:(NSInteger)action;

///根据@姓名获取uid
+(long long)getUidByAtName:(NSString *)name fromAtList:(NSArray *)atList;



#pragma mark- 初始化OA和CRM功能模块
+(void)initOAandCRMModuleOption;
#pragma mark  初始化OA模块选择
+(void)initOaModuleOption;
#pragma mark  初始化CRM模块选择
+(void)initCRMModuleOption;

#pragma mark 根据用户选择  设置显示项(办公/CRM)
+(NSArray *)getOptionsModuleShow:(NSArray *)moduleOptions;



#pragma mark - 根据手机名称获取联系人信息
///根据手机号获取当前联系人
+(AddressBook *)getContactNameByMobile:(NSString *)mobile;


#pragma mark - 从文件读取缓存的动态数据（1页）
+(void)getDynamicCacheData;

#pragma mark - 拨打电话或发送短信时标记联系人为最近联系人
+(void)setLatelyContactByMobile:(NSString *)mobile;

@end
