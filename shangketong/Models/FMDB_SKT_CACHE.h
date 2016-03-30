//
//  FMDB_SKT_CACHE.h
//  shangketong
//
//  Created by sungoin-zjp on 15-7-23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB.h>

@class AddressBook;
@class Campaign;

@interface FMDB_SKT_CACHE : NSObject

////置空
+(void)setFMDB_SKT_CACHE_NULL:(FMDatabase *)sdb;
///关闭数据库
+(void)closeDataBase;


#pragma mark - 通讯录数据逻辑处理相关操作
///将通讯录保存到数据库
+(void)saveAddressBookDataToSQL:(NSArray *)resultArray;
/// 根据返回的联系人status  修改本地缓存数据
/// status 2已激活,3离职,4禁用
+(void)optionAddressByAddressStatus:(NSArray *)arrayAddress;



#pragma mark  通讯录相关操作
///插入数据
+(BOOL)insert_AddressBook_ContactInfo:(AddressBook *)addressbook;
///根据联系人id做删除操作
+(void)delete_AddressBook_ContactId:(NSInteger)userId;
///根据联系人id判断联系人是否已经存在
+(BOOL)isExist_AddressBook_ContactId:(NSInteger)userId;
///更新通讯录联系人信息
+(void)update_AddressBook_ContactNewInfo:(AddressBook *)addressbook;
///查询所有通讯录数据
+ (NSMutableArray*)select_AddressBook_AllData;
///删除所有数据缓存
+(void)delete_AddressBook_AllDataCache;




#pragma mark - 最近联系人
+(BOOL)insert_AddressBook_LatelyContactInfo:(AddressBook *)addressbook;
///查询所有最近联系人数据
+ (NSMutableArray*)select_AddressBook_LatelyContact_AllData;
///删除所有数据缓存
+(void)delete_AddressBook_LatelyContact_AllDataCache;
///将最近联系人保存到数据库
+(void)saveLatelyContactDataToSQL:(NSArray *)resultArray;




#pragma mark - CRM缓存相关  (插入/删除/查询)

///插入数据 Campaign(活动市场)
+(BOOL)insert_Campaign_CampaignInfo:(Campaign *)campaign;
///更新市场活动信息
+(void)update_Campaign_CampaignNewInfo:(Campaign *)campaign;
///查询所有Campaign(活动市场)数据
+ (NSMutableArray*)select_Campaign_AllData;
///删除所有数据缓存 Campaign(活动市场)
+(void)delete_Campaign_AllDataCache;
///将通讯录保存到数据库
+(void)saveCampaignDataToSQL:(NSArray *)resultArray;





@end
