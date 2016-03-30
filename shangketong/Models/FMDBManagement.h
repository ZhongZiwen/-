//
//  FMDBManagement.h
//  shangketong
//
//  Created by sungoin-zbs on 15/9/7.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kTableName_activity @"activity"
#define kIndexStatus_activity @"indexStatus_activity"
#define kSortStatus_activity @"sortStatus_activyty"
#define kSearch_activity @"search_activity"

#define kTableName_lead @"lead"
#define kIndexStatus_lead @"indexStatus_lead"
#define kSortStatus_lead @"sortStatus_lead"
#define kSearch_lead @"search_lead"

#define kTableName_customer @"customer"
#define kIndexStatus_customer @"indexStatus_customer"
#define kSortStatus_customer @"sortStatus_customer"
#define kSearch_customer @"search_customer"

#define kTableName_contact @"contact"
#define kIndexStatus_contact @"indexStatus_contact"
#define kSortStatus_contact @"sortStatus_contact"
#define kSearch_contact @"search_contact"

#define kTableName_opportunity @"opportunity"
#define kIndexStatus_opportunity @"indexStatus_opportunity"
#define kSortStatus_opportunity @"sortStatus_opportunity"
#define kSearch_opportunity @"search_opportunity"

@class User, AddressBook, ActivityModel;

@interface FMDBManagement : NSObject

+ (NSString*)databaseFilePath;

+ (FMDBManagement*)sharedFMDBManager;

// 删除数据库
- (void)deleteFMDB;


// 缓存登陆数据
- (void)addUserModel:(User*)user;
// 去登陆缓存数据
- (User*)getCurrentUser;

// 快捷操作
- (void)createQuickTable;
- (void)casheQuickWithArray:(NSArray*)array;
- (NSMutableArray*)getQuickDataSource;

// 创建通讯录表
- (void)creatAddressBookTable;
- (void)saveAddressModel:(AddressBook*)item;
- (void)insertAddressBookWithArray:(NSArray *)array;    // 第一次请求通讯录数据
- (void)updateAddressBookWithArray:(NSArray *)array;    // 增量跟新通讯录数据
- (NSMutableArray*)getAddressBookDataSource;
- (NSString*)selectAddressBookNameById:(NSNumber *)mid;

// 通讯录最近联系人
- (void)creatRecentlyAddressBookTable;
- (void)casheRecentlyAddressBookWithItem:(AddressBook*)item;
- (NSMutableArray*)getRecentlyAddressBookDataSource;

// CRM缓存
// CRM--最近浏览
- (void)creatCRMRecentlyTableWithName:(NSString*)tableName;
- (void)casheCRMRecentlyDataSourceWithName:(NSString*)tableName item:(id)obj;
- (void)deleteCRMRecentyDataSourceWithName:(NSString*)tableName item:(id)obj;
- (NSMutableArray*)getCRMRecentlyDataSourceWithName:(NSString*)tableName;

// CRM--搜索
- (void)createCRMSearchTableWithName:(NSString*)tableName;
- (void)casheCRMSearchDataSourceWithTableName:(NSString*)tableName item:(id)obj;
- (BOOL)deleteCRMSearchDataSourceWithTableName:(NSString*)tableName;
- (NSMutableArray*)getCRMSearchDataSourceWithTableName:(NSString*)tableName;

// CRM--索引、筛选、列表
- (void)creatCRMTableWithName:(NSString*)tableName;
- (void)casheCRMDataSourceWithName:(NSString*)tableName array:(NSArray*)array conditionId:(NSNumber*)conditionId sortId:(NSNumber*)sortId;
- (NSMutableArray*)getCRMDataWithName:(NSString*)tableName conditionId:(NSNumber*)conditionId sortId:(NSNumber*)sortId;

//OA  工作报告
- (void)creatWorkResportWithBaseName:(NSString *)baseName;
- (void)insertOrUpdateDataSourceWithName:(NSString *)tableName array:(NSArray *)array conditionId:(NSNumber *)conditionId sortId:(NSNumber *)sortId;
- (NSMutableArray*)resultDataWithName:(NSString *)tableName conditionId:(NSNumber *)conditionId sortId:(NSNumber *)sortId;


- (void)creatWorkResportIndexPathWithBaseName:(NSString *)baseName;
- (void)insertWorkResportIndexPathWithName:(NSString *)tableName WithUserId:(NSString *)userId WithIndexPathSecation:(NSNumber *)secation WithIndexPathRow:(NSNumber *)row;
- (NSDictionary *)resultWorkResportIndexPathWithName:(NSString *)tableName WithUserId:(NSString *)userId;
//工作报告 审批 选择抄送人
- (void)creatLastContactsAddressBookTable;
- (void)insertLastContactsAddressBookWithItem:(AddressBook*)item;
- (NSMutableArray*)getLastContactsAddressBookDataSource;
- (void)deleteLastContactsAddressBookList;
@end
