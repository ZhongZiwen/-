//
//  FMDB_SKT_CACHE.m
//  shangketong
//  数据缓存
//  Created by sungoin-zjp on 15-7-23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "FMDB_SKT_CACHE.h"
#import "NSUserDefaults_Cache.h"

#import "AddressBook.h"
#import "Campaign.h"

static FMDatabase *shareDataBase = nil;
static NSString *const fmdbFilePath = @"fmdb_skt_cache.sqlite";
static NSString *const tablename_addressbook = @"ADDRESSBOOK";
static NSString *const tablename_latelycontact = @"ADDRESSBOOK_LATELY_CONTACT";
static NSString *const tablename_campaign = @"CAMPAIGN";

@interface FMDB_SKT_CACHE ()


@end

@implementation FMDB_SKT_CACHE


+(FMDatabase *)createDataBase{
    //同步锁写法
    @synchronized(self){
        if (!shareDataBase) {
            NSLog(@"----createDataBase----->");
            ///使用登录返回的id 来区分不同帐号
            NSDictionary *userInfo = [NSUserDefaults_Cache getUserInfo];
            NSString *userId = [userInfo safeObjectForKey:@"id"] ;
            NSString *fmdbpath = [NSString stringWithFormat:@"%@_%@_%@",userId,userId,fmdbFilePath];
            shareDataBase = [FMDatabase databaseWithPath:[self filePaths:fmdbpath]];
            NSLog(@"fmdbpath:%@",fmdbpath);
            if (![shareDataBase open]) {
                NSLog(@"数据库打开失败");
                
            }else{
                ///通讯录数据表
                NSString *sqlStrAddress = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(id INTEGER, icon text, name text, pinyin text, depart text, mobile text, phone text, extensionNumber text, position text, focused INTEGER)",tablename_addressbook];
                
                ///最近联系人数据表
                NSString *sqlStrLatelyContact = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(id INTEGER, icon text, name text, pinyin text, depart text, mobile text, phone text, extensionNumber text, position text, focused INTEGER)",tablename_latelycontact];
                
                ///市场活动数据表
                NSString *sqlStrCampaign = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(id text, name text, focus text)",tablename_campaign];
                
                [shareDataBase executeUpdate:sqlStrAddress];
                [shareDataBase executeUpdate:sqlStrLatelyContact];
                [shareDataBase executeUpdate:sqlStrCampaign];
            }
        }
    }
    return shareDataBase;
}

///置空
+(void)setFMDB_SKT_CACHE_NULL:(FMDatabase *)sdb
{
    shareDataBase = sdb;
}

/*
+ (FMDatabase *)createDataBase {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ///使用登录返回的id 来区分不同帐号
        NSDictionary *userInfo = [NSUserDefaults_Cache getUserInfo];
        NSString *userId = [userInfo safeObjectForKey:@"id"] ;
        NSString *fmdbpath = [NSString stringWithFormat:@"%@_%@_%@",userId,userId,fmdbFilePath];
        shareDataBase = [FMDatabase databaseWithPath:[self filePaths:fmdbpath]];
        NSLog(@"fmdbpath:%@",fmdbpath);
        if (![shareDataBase open]) {
            NSLog(@"数据库打开失败");
            return;
        }
        
        ///通讯录数据表
        NSString *sqlStr = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(userId INTEGER, icon text, name text, pinyin text, depart text, mobile text, phone text, extensionNumber text, position text, focused INTEGER)",tablename_addressbook];
        
        [shareDataBase executeUpdate:sqlStr];
    });
    return shareDataBase;
}
 */


/**
 关闭数据库
 **/
+(void)closeDataBase {
    if(![shareDataBase close]) {
        NSLog(@"数据库关闭异常");
        return;
    }
}


#pragma mark - 通讯录相关逻辑处理
///将通讯录保存到数据库
+(void)saveAddressBookDataToSQL:(NSArray *)resultArray{
    NSInteger count = 0;
    if (resultArray ) {
        count = [resultArray count];
    }
//    for (int i = 0; i < count; i ++) {
//        NSDictionary *dict = [resultArray objectAtIndex:i];
//        AddressBook *item = [AddressBook initWithDictionary:dict];
//        [FMDB_SKT_CACHE insert_AddressBook_ContactInfo:item];
//    }
}

/// 根据返回的联系人status  修改本地缓存数据
/// status 2已激活,3离职,4禁用
+(void)optionAddressByAddressStatus:(NSArray *)arrayAddress{
    NSInteger count = 0;
    if (arrayAddress) {
        count = [arrayAddress count];
    }
    
//    NSInteger status = 0;
//    for (int i=0; i<count; i++) {
//        status = [[[arrayAddress objectAtIndex:i] safeObjectForKey:@"status"] integerValue];
//        ///新增
//        if (status == 2) {
//            NSLog(@"有新增联系人");
//            AddressBook *item = [AddressBook initWithDictionary:[arrayAddress objectAtIndex:i]];
//            ///如果存在 则更新
//            if ([FMDB_SKT_CACHE isExist_AddressBook_ContactId:item.m_userid]) {
//                [FMDB_SKT_CACHE update_AddressBook_ContactNewInfo:item];
//                NSLog(@"");
//            }else{
//                ///不存在 插入
//                [FMDB_SKT_CACHE insert_AddressBook_ContactInfo:item];
//            }
//        }else if (status == 3 || status == 4) {
//            NSLog(@"有禁用联系人");
//            ///从缓存里删除
//            [FMDB_SKT_CACHE delete_AddressBook_ContactId:[[[arrayAddress objectAtIndex:i] safeObjectForKey:@"id"] integerValue]];
//        }
//    }
}


#pragma mark  通讯录相关存储操作
+(BOOL)insert_AddressBook_ContactInfo:(AddressBook *)addressbook{
    BOOL isOk = NO;
    shareDataBase = [FMDB_SKT_CACHE createDataBase];
//    if ([shareDataBase open]) {
//         NSString *sqlStr = [NSString stringWithFormat:@"insert into %@(id, icon, name, pinyin, depart , mobile, phone, extensionNumber , position , focused) values ('%ti', '%@','%@','%@','%@','%@','%@','%@','%@','%ti')", tablename_addressbook, addressbook.m_userid, addressbook.m_icon,addressbook.m_name,addressbook.m_pinyin,addressbook.m_depart,addressbook.m_mobile,addressbook.m_phone,addressbook.m_extensionNumber,addressbook.m_position,addressbook.m_focused];
//        isOk = [shareDataBase executeUpdate:sqlStr];
//        if (isOk) {
//            NSLog(@"插入成功");
//        }else{
//            NSLog(@"插入失败");
//        }
//    }
    return isOk;
}

///根据联系人id做删除操作
+(void)delete_AddressBook_ContactId:(NSInteger)userId{
    shareDataBase = [FMDB_SKT_CACHE createDataBase];
    if ([shareDataBase open]) {
        NSString *sqlStr = [NSString stringWithFormat:@"DELETE FROM %@ WHERE id = '%ti'", tablename_addressbook,userId];
        BOOL res = [shareDataBase executeUpdate:sqlStr];
        if (res) {
            NSLog(@"删除成功");
        }else{
            NSLog(@"删除失败");
        }
//        [shareDataBase close];
    }
}

///联系人是否已经存在
+(BOOL)isExist_AddressBook_ContactId:(NSInteger)userId{
    BOOL isExist = FALSE;
    shareDataBase = [FMDB_SKT_CACHE createDataBase];
    if ([shareDataBase open]) {
        NSString *sqlStr = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE  id = '%ti'", tablename_addressbook,userId];
        FMResultSet *resultSet = [shareDataBase executeQuery:sqlStr];
        if ([resultSet next]) {
            if ([resultSet intForColumn:@"id"]) {
                isExist = TRUE;
                NSLog(@"联系人存在id:%i  name:%@",[resultSet intForColumn:@"id"],[resultSet stringForColumn:@"name"]);
            }
        }else{
            isExist = FALSE;
            NSLog(@"联系人不存在");
        }
    }
    return isExist;
}



///更新通讯录联系人信息
+(void)update_AddressBook_ContactNewInfo:(AddressBook *)addressbook{
    shareDataBase = [FMDB_SKT_CACHE createDataBase];
//    if ([shareDataBase open]) {
//         NSString *sqlStr = [NSString stringWithFormat:@"UPDATE %@ SET  icon = '%@', name = '%@', pinyin = '%@', depart = '%@' , mobile = '%@', phone = '%@', extensionNumber = '%@' , position = '%@', focused = '%ti' WHERE id = '%ti'", tablename_addressbook,addressbook.m_icon,addressbook.m_name,addressbook.m_pinyin,addressbook.m_depart,addressbook.m_mobile,addressbook.m_phone,addressbook.m_extensionNumber,addressbook.m_position,addressbook.m_focused,addressbook.m_userid];
//        
////        NSLog(@"sqlStr:%@",sqlStr);
//        BOOL res = [shareDataBase executeUpdate:sqlStr];
//        if (res) {
//            NSLog(@"修改成功");
//        }else{
//            NSLog(@"修改失败");
//        }
//        [shareDataBase close];
//    }
}

///查询所有通讯录数据
+ (NSMutableArray*)select_AddressBook_AllData
{
    NSString *sqlStr = [NSString stringWithFormat:@"SELECT * FROM %@", tablename_addressbook];
    
    NSMutableArray *array = [NSMutableArray array];
    shareDataBase = [FMDB_SKT_CACHE createDataBase];
//    if ([shareDataBase open]) {
//        FMResultSet *resultSet = [shareDataBase executeQuery:sqlStr];
//         while([resultSet next]) {
//            AddressBook *addressbook = [[AddressBook alloc] init];
//             addressbook.m_userid = [resultSet intForColumn:@"id"];
//             addressbook.m_icon = [resultSet stringForColumn:@"icon"];
//             addressbook.m_name = [resultSet stringForColumn:@"name"];
//             addressbook.m_pinyin = [resultSet stringForColumn:@"pinyin"];
//             addressbook.m_depart = [resultSet stringForColumn:@"depart"];
//             addressbook.m_mobile = [resultSet stringForColumn:@"mobile"];
//             addressbook.m_phone = [resultSet stringForColumn:@"phone"];
//             addressbook.m_extensionNumber = [resultSet stringForColumn:@"extensionNumber"];
//             addressbook.m_position = [resultSet stringForColumn:@"position"];
//             addressbook.m_focused = [resultSet intForColumn:@"focused"];
//
//             [array addObject:addressbook];
//        }
////        [shareDataBase close];
//    }
    
    return array;
}



///删除所有数据缓存
+(void)delete_AddressBook_AllDataCache{
    shareDataBase = [FMDB_SKT_CACHE createDataBase];
    if ([shareDataBase open]) {

        NSString *sqlstrDelete = [NSString stringWithFormat:@"DELETE FROM %@", tablename_addressbook];
        BOOL resDelete = [shareDataBase executeUpdate:sqlstrDelete];
        if (resDelete) {
            NSLog(@"清除表成功");
        }else{
            NSLog(@"清除表失败");
        }
        
        /*
         NSString *sqlStrDrop = [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@",tablename_addressbook];
         BOOL resDrop = [shareDataBase executeUpdate:sqlStrDrop];
         if (resDrop) {
         NSLog(@"删除表成功");
         }else{
         NSLog(@"删除表失败");
         }
         
        NSString *sqlStr = [NSStering stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(userId INTEGER, icon text, name text, pinyin text, depart text, mobile text, phone text, extensionNumber text, position text, focused INTEGER)",tablename_addressbook];
        
        BOOL resCreate = [shareDataBase executeUpdate:sqlStr];
        if (resCreate) {
            NSLog(@"创建表成功");
        }else{
            NSLog(@"创建表失败");
        }
         */
    }
}


#pragma mark - 最近联系人
+(BOOL)insert_AddressBook_LatelyContactInfo:(AddressBook *)addressbook{
    BOOL isOk = NO;
//    shareDataBase = [FMDB_SKT_CACHE createDataBase];
//    if ([shareDataBase open]) {
//        NSString *sqlStr = [NSString stringWithFormat:@"insert into %@(id, icon, name, pinyin, depart , mobile, phone, extensionNumber , position , focused) values ('%ti', '%@','%@','%@','%@','%@','%@','%@','%@','%ti')", tablename_latelycontact, addressbook.m_userid, addressbook.m_icon,addressbook.m_name,addressbook.m_pinyin,addressbook.m_depart,addressbook.m_mobile,addressbook.m_phone,addressbook.m_extensionNumber,addressbook.m_position,addressbook.m_focused];
//        isOk = [shareDataBase executeUpdate:sqlStr];
//        if (isOk) {
//            NSLog(@"插入成功");
//        }else{
//            NSLog(@"插入失败");
//        }
//    }
    return isOk;
}

///查询所有最近联系人数据
+ (NSMutableArray*)select_AddressBook_LatelyContact_AllData
{
    NSString *sqlStr = [NSString stringWithFormat:@"SELECT * FROM %@", tablename_latelycontact];
    
    NSMutableArray *array = [NSMutableArray array];
//    shareDataBase = [FMDB_SKT_CACHE createDataBase];
//    if ([shareDataBase open]) {
//        FMResultSet *resultSet = [shareDataBase executeQuery:sqlStr];
//        while([resultSet next]) {
//            AddressBook *addressbook = [[AddressBook alloc] init];
//            addressbook.m_userid = [resultSet intForColumn:@"id"];
//            addressbook.m_icon = [resultSet stringForColumn:@"icon"];
//            addressbook.m_name = [resultSet stringForColumn:@"name"];
//            addressbook.m_pinyin = [resultSet stringForColumn:@"pinyin"];
//            addressbook.m_depart = [resultSet stringForColumn:@"depart"];
//            addressbook.m_mobile = [resultSet stringForColumn:@"mobile"];
//            addressbook.m_phone = [resultSet stringForColumn:@"phone"];
//            addressbook.m_extensionNumber = [resultSet stringForColumn:@"extensionNumber"];
//            addressbook.m_position = [resultSet stringForColumn:@"position"];
//            addressbook.m_focused = [resultSet intForColumn:@"focused"];
//            
//            [array addObject:addressbook];
//        }
//        //        [shareDataBase close];
//    }
    
    return array;
}

///删除所有数据缓存
+(void)delete_AddressBook_LatelyContact_AllDataCache{
    shareDataBase = [FMDB_SKT_CACHE createDataBase];
    if ([shareDataBase open]) {
        
        NSString *sqlstrDelete = [NSString stringWithFormat:@"DELETE FROM %@", tablename_latelycontact];
        BOOL resDelete = [shareDataBase executeUpdate:sqlstrDelete];
        if (resDelete) {
            NSLog(@"清除表成功");
        }else{
            NSLog(@"清除表失败");
        }
    }
}

///将最近联系人保存到数据库
+(void)saveLatelyContactDataToSQL:(NSArray *)resultArray{
    NSInteger count = 0;
    if (resultArray ) {
        count = [resultArray count];
    }
    for (int i = 0; i < count; i ++) {
        NSDictionary *dict = [resultArray objectAtIndex:i];
//        AddressBook *item = [AddressBook initWithDictionary:dict];
        [FMDB_SKT_CACHE insert_AddressBook_LatelyContactInfo:[resultArray objectAtIndex:i]];
    }
}


#pragma mark - CRM缓存相关  (插入/删除/查询/修改)

#pragma mark 市场活动
///插入数据 Campaign(活动市场)
+(BOOL)insert_Campaign_CampaignInfo:(Campaign *)campaign{
    BOOL isOk = NO;
    shareDataBase = [FMDB_SKT_CACHE createDataBase];
    if ([shareDataBase open]) {
        NSString *sqlStr = [NSString stringWithFormat:@"insert into %@(id, name, focus) values ('%@', '%@','%@')", tablename_campaign, campaign.m_uid, campaign.m_name,campaign.m_focus];
        isOk = [shareDataBase executeUpdate:sqlStr];
        if (isOk) {
            NSLog(@"插入成功");
        }else{
            NSLog(@"插入失败");
        }
    }
    return isOk;
}


///更新市场活动信息
+(void)update_Campaign_CampaignNewInfo:(Campaign *)campaign{
    shareDataBase = [FMDB_SKT_CACHE createDataBase];
    if ([shareDataBase open]) {
        NSString *sqlStr = [NSString stringWithFormat:@"UPDATE %@ SET  focus = '%@' WHERE id = '%@'", tablename_campaign,campaign.m_focus,campaign.m_uid];
        
        //        NSLog(@"sqlStr:%@",sqlStr);
        BOOL res = [shareDataBase executeUpdate:sqlStr];
        if (res) {
            NSLog(@"修改成功");
        }else{
            NSLog(@"修改失败");
        }
        [shareDataBase close];
    }
}

///查询所有Campaign(活动市场)数据
+ (NSMutableArray*)select_Campaign_AllData
{
    NSString *sqlStr = [NSString stringWithFormat:@"SELECT * FROM %@", tablename_campaign];
    
    NSMutableArray *array = [NSMutableArray array];
    shareDataBase = [FMDB_SKT_CACHE createDataBase];
    if ([shareDataBase open]) {
        FMResultSet *resultSet = [shareDataBase executeQuery:sqlStr];
        while([resultSet next]) {
            Campaign *campaign = [[Campaign alloc] init];
            campaign.m_uid = [resultSet stringForColumn:@"id"];
            campaign.m_name = [resultSet stringForColumn:@"name"];
            campaign.m_focus = [resultSet stringForColumn:@"focus"];
            [array addObject:campaign];
        }
        //        [shareDataBase close];
    }
    
    return array;
}

///删除所有数据缓存 Campaign(活动市场)
+(void)delete_Campaign_AllDataCache{
    shareDataBase = [FMDB_SKT_CACHE createDataBase];
    if ([shareDataBase open]) {
        NSString *sqlstrDelete = [NSString stringWithFormat:@"DELETE FROM %@", tablename_campaign];
        BOOL resDelete = [shareDataBase executeUpdate:sqlstrDelete];
        if (resDelete) {
            NSLog(@"清除表成功");
        }else{
            NSLog(@"清除表失败");
        }
    }
}


///将市场活动保存到数据库
+(void)saveCampaignDataToSQL:(NSArray *)resultArray{
    NSInteger count = 0;
    if (resultArray ) {
        count = [resultArray count];
    }
    for (int i = 0; i < count; i ++) {
        NSDictionary *dict = [resultArray objectAtIndex:i];
        Campaign *item = [Campaign initWithDictionary:dict];
        [FMDB_SKT_CACHE insert_Campaign_CampaignInfo:item];
    }
}


#pragma mark - 路径
+ (NSString*) filePaths:(NSString*)fileName
{
    NSString* documentDirectory = [NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString* _filePath = [documentDirectory stringByAppendingPathComponent:fileName];
    
    return _filePath;
}

@end
