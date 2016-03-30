//
//  FMDBManagement.m
//  shangketong
//
//  Created by sungoin-zbs on 15/9/7.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "FMDBManagement.h"
#import <FMDB.h>
#import "User.h"
#import "AddressBook.h"
#import "ActivityModel.h"
#import "Lead.h"
#import "Customer.h"
#import "Contact.h"
#import "SaleChance.h"
#import "Quick.h"

static NSString *const dataSourcePath = @"dataSource.sqlite";
static NSString *const table_addressBook = @"addressBook";      // 通讯录
static NSString *const table_recentlyAddressBook = @"recentlyAddressBook"; // 最近联系人
static NSString *const table_quick = @"quick";                  // 快捷操作
static NSString *const WORKRESPORT = @"workresport"; //工作报告
static NSString *const OA_LASTCONTACTLIST = @"OALASTCONTACTLIST"; //OA最近联系人

@interface FMDBManagement ()

@property (strong, nonatomic) FMDatabase *dataBase;
@property (strong, nonatomic) FMDatabaseQueue *dataBaseQueue;
@end

@implementation FMDBManagement

+ (NSString*)databaseFilePath {
    NSArray *filePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [filePath lastObject];
    NSLog(@"filePath = %@", filePath);
    NSString *dbFilePath = [documentPath stringByAppendingPathComponent:dataSourcePath];
    return dbFilePath;
}

+ (FMDBManagement*)sharedFMDBManager {
    static dispatch_once_t onceToken;
    static FMDBManagement *management = nil;
    dispatch_once(&onceToken, ^{
        management = [[FMDBManagement alloc] init];
    });
    return management;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self creatDatabase];
    }
    return self;
}

// 创建数据库
- (void)creatDatabase {
    _dataBase = [FMDatabase databaseWithPath:[FMDBManagement databaseFilePath]];
    _dataBaseQueue = [FMDatabaseQueue databaseQueueWithPath:[FMDBManagement databaseFilePath]];
}

- (void)deleteFMDB {
    BOOL success;
    NSError *error;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // delete the old db.
    if ([fileManager fileExistsAtPath:[FMDBManagement databaseFilePath]]) {
        [_dataBase close];
        _dataBase = nil;
        _dataBaseQueue = nil;
        success = [fileManager removeItemAtPath:[FMDBManagement databaseFilePath] error:&error];
        if (!success) {
            NSAssert1(0, @"Failed to delete old database file with message '%@'.", [error localizedDescription]);
        }
    }
}

// 创建表
- (void)creatTable {
    
    // 先判断数据库是否存在，如果不存在，创建数据库
    if (!_dataBase) {
        [self creatDatabase];
    }
    
    // 判断数据库是否已经打开
    if (![_dataBase open]) {
        return;
    }
    
    // 为数据库设置缓存，提高查询效率
    [_dataBase setShouldCacheStatements:YES];
    
    // 判断数据库中是否已经存在这个表，如果不存在则创建该表
    // 创建login表
    if (![_dataBase tableExists:@"login"]) {
        [_dataBase executeUpdate:@"create table login(id integer primary key autoincrement, user_id integer, model blob)"];
    }
    // 创建通讯录表
    if (![_dataBase tableExists:@"addressBook"]) {
        [_dataBase executeUpdate:@"create table addressBook(id integer primary key autoincrement, user_id integer, model blob)"];
    }

    [_dataBase close];
}

- (void)addUserModel:(User *)user {
    
    // 判断数据库是否已经打开
    if (![_dataBase open]) {
        return;
    }
    
    //把模型通过归档转换成二进制数据
    NSData *modelData = [NSKeyedArchiver archivedDataWithRootObject:user];

//    [_dataBase executeUpdate:@"insert into login (user_id, model) values (?, ?)", user.id, modelData];

    // 向login表中查询有没有相同的用户，如果有，做修改操作
    FMResultSet *resultSet = [_dataBase executeQuery:@"select * from login where user_id = ?", user.id];

    if ([resultSet next]) { // 存在该用户
        [_dataBase executeUpdate:@"update login set model = ? where user_id = ?", modelData, user.id];
    }else { // 不存在该用户，向login表中插入一条数据
        [_dataBase executeUpdate:@"insert into login (user_id, model) values (?, ?)", user.id, modelData];
    }
    
    [_dataBase close];
}

- (User*)getCurrentUser {
    // 判断数据库是否已经打开
    if (![_dataBase open]) {
        return nil;
    }
    
    FMResultSet *resultSet = [_dataBase executeQuery:@"SELECT * FROM login"];
    User *user = nil;
    while ([resultSet next]) {
        //取出模型数据
        NSData *data = [resultSet dataForColumn:@"model"];
        //反归档
        user = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    [_dataBase close];
    
    return user;
}

#pragma mark - 快捷操作
- (void)createQuickTable {
    // 先判断数据库是否存在，如果不存在，创建数据库
    if (!_dataBase) {
        [self creatDatabase];
    }
    
    // 判断数据库是否已经打开
    if (![_dataBase open]) {
        return;
    }
    
    // 为数据库设置缓存，提高查询效率
    [_dataBase setShouldCacheStatements:YES];
    
    // 判断数据库中是否已经存在这个表，如果不存在则创建该表
    // 创建通讯录表
    if (![_dataBase tableExists:table_quick]) {
        [_dataBase executeUpdate:[NSString stringWithFormat:@"create table %@(id integer primary key autoincrement, model blob)", table_quick]];
        
        NSArray *imagesArray = @[@"feed", @"account", @"schedule", @"sign", @"scan", @"approlval", @"contact", @"lead", @"task", @"workreport", @"opp", @"send_message"];
        NSArray *titlesArray = @[@"发布动态", @"新建客户", @"新建日程", @"快速签到", @"名片扫描", @"提交审批", @"新建联系人", @"新建销售线索", @"新建任务", @"新建工作报告", @"新建销售机会", @"群发短信"];
        NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:imagesArray.count];
        for (int i = 0; i < imagesArray.count; i ++) {
            Quick *item = [[Quick alloc] init];
            item.imageString = imagesArray[i];
            item.titleString = titlesArray[i];
            if (i < 5) {
                item.isSelected = @1;
            }
            else {
                item.isSelected = @0;
            }
            [tempArray addObject:item];
        }
        [self casheQuickWithArray:tempArray];
    }
    
    [_dataBase close];
}

- (void)casheQuickWithArray:(NSArray *)array {
    if (![_dataBase open]) {
        return;
    }
    
    for (int i = 0; i < array.count; i ++) {
        [_dataBase executeUpdate:[NSString stringWithFormat:@"delete from %@ where id = ?", table_quick], @(i)];
    }

    for (int i = 0; i < array.count; i ++) {
        Quick *item = array[i];
        // 将模型通过归档转换成二进制数据
        NSData *modelData = [NSKeyedArchiver archivedDataWithRootObject:item];
        
        [_dataBase executeUpdate:[NSString stringWithFormat:@"insert into %@(id, model) values (?, ?)", table_quick], @(i), modelData];
    }
    [_dataBase close];
}

- (NSMutableArray*)getQuickDataSource {
    if (![_dataBase open])
        return nil;
    
    FMResultSet *resultSet = [_dataBase executeQuery:[NSString stringWithFormat:@"select * from %@", table_quick]];
    
    NSMutableArray *sourceArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    while ([resultSet next]) {
        // 取出模型数据
        NSData *data = [resultSet dataForColumn:@"model"];
        // 反归档
        Quick *item = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        [sourceArray addObject:item];
    }
    
    [_dataBase close];
    
    return sourceArray;
}

#pragma mark - 通讯录
- (void)creatAddressBookTable {
    // 先判断数据库是否存在，如果不存在，创建数据库
    if (!_dataBase) {
        [self creatDatabase];
    }
    
    // 判断数据库是否已经打开
    if (![_dataBase open]) {
        return;
    }
    
    // 为数据库设置缓存，提高查询效率
    [_dataBase setShouldCacheStatements:YES];
    
    // 判断数据库中是否已经存在这个表，如果不存在则创建该表
    // 创建通讯录表
    if (![_dataBase tableExists:table_addressBook]) {
        [_dataBase executeUpdate:[NSString stringWithFormat:@"create table %@(id integer primary key autoincrement, user_id integer, model blob)", table_addressBook]];
    }
    
    [_dataBase close];
}

- (void)saveAddressModel:(AddressBook *)item {
    // 删除联系人
    if ([item.status isEqualToNumber:@3] || [item.status isEqualToNumber:@4]) {
        [_dataBase executeUpdate:[NSString stringWithFormat:@"delete from %@ where user_id = ?", table_addressBook], item.id];
        [_dataBase close];
        return;
    }
    
    // 将模型通过归档转换成二进制数据
    NSData *modelData = [NSKeyedArchiver archivedDataWithRootObject:item];
    
    FMResultSet *resultSet = [_dataBase executeQuery:[NSString stringWithFormat:@"select * from %@ where user_id = ?", table_addressBook], item.id];
    
    if ([resultSet next]) {
        [_dataBase executeUpdate:[NSString stringWithFormat:@"update %@ set model = ? where user_id = ?", table_addressBook], modelData, item.id];
    }else {
        [_dataBase executeUpdate:[NSString stringWithFormat:@"insert into %@(user_id, model) values (?, ?)", table_addressBook], item.id, modelData];
    }
}

- (void)insertAddressBookWithArray:(NSArray *)array {
//    NSDate *date = [NSDate date];
    dispatch_queue_t queue = dispatch_queue_create("queueOne", NULL);
    dispatch_async(queue, ^{
        [_dataBaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            [db shouldCacheStatements];
            [array enumerateObjectsUsingBlock:^(AddressBook *item, NSUInteger idx, BOOL *stop) {
                NSData *modelData = [NSKeyedArchiver archivedDataWithRootObject:item];
                BOOL res = [db executeUpdate:[NSString stringWithFormat:@"insert into %@(user_id, model) values (?, ?)", table_addressBook], item.id, modelData];
                if (!res) {
//                    NSLog(@"error to inster data: %@", item.name);
                } else {
//                    NSLog(@"succuss to inster data: %@", item.name);
                }
            }];
        }];
    });

//    float interval = [[NSDate date] timeIntervalSinceDate:date];
//    NSLog(@"总耗时：%f", interval);
}

- (void)updateAddressBookWithArray:(NSArray *)array {
    if (![_dataBase open]) {
        return;
    }
    
    [_dataBase shouldCacheStatements];
    [_dataBase beginTransaction];
    
    [array enumerateObjectsUsingBlock:^(AddressBook *item, NSUInteger idx, BOOL *stop) {
        
        // 删除联系人
        if ([item.status isEqualToNumber:@3] || [item.status isEqualToNumber:@4]) {
            [_dataBase executeUpdate:[NSString stringWithFormat:@"delete from %@ where user_id = ?", table_addressBook], item.id];
            [_dataBase close];
            return;
        }
        
        // 将模型通过归档转换成二进制数据
        NSData *modelData = [NSKeyedArchiver archivedDataWithRootObject:item];
        
        FMResultSet *resultSet = [_dataBase executeQuery:[NSString stringWithFormat:@"select * from %@ where user_id = ?", table_addressBook], item.id];
        
        if ([resultSet next]) {
            [_dataBase executeUpdate:[NSString stringWithFormat:@"update %@ set model = ? where user_id = ?", table_addressBook], modelData, item.id];
        }else {
            [_dataBase executeUpdate:[NSString stringWithFormat:@"insert into %@(user_id, model) values (?, ?)", table_addressBook], item.id, modelData];
        }
    }];
    
    //提交事务
    if([_dataBase commit]) {
    }
    else {
    }
    
    [_dataBase close];
}

- (NSMutableArray*)getAddressBookDataSource {
    if (![_dataBase open])
        return nil;
    
    FMResultSet *resultSet = [_dataBase executeQuery:[NSString stringWithFormat:@"select * from %@", table_addressBook]];
    
    NSMutableArray *sourceArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    while ([resultSet next]) {
        // 取出模型数据
        NSData *data = [resultSet dataForColumn:@"model"];
        // 反归档
        AddressBook *item = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        [sourceArray addObject:item];
    }
    
    [_dataBase close];
    
    return sourceArray;
}


////通过联系人ID获取其nane
- (NSString*)selectAddressBookNameById:(NSNumber *)mid {
    if (![_dataBase open])
        return nil;
    
    FMResultSet *resultSet = [_dataBase executeQuery:[NSString stringWithFormat:@"select * from %@ where user_id = ?", table_addressBook], mid];
    
    if ([resultSet next]) {
        NSData *data = [resultSet dataForColumn:@"model"];
        // 反归档
        AddressBook *item = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        return item.name;
    }
    [_dataBase close];
   return @"";
}



#pragma mark - 最近联系人
- (void)creatRecentlyAddressBookTable {
    if (!_dataBase) {
        [self creatDatabase];
    }
    
    if (![_dataBase open]) {
        return;
    }
    
    [_dataBase setShouldCacheStatements:YES];
    
    if (![_dataBase tableExists:table_recentlyAddressBook]) {
        [_dataBase executeUpdate:[NSString stringWithFormat:@"create table %@(id integer primary key autoincrement, model blob)", table_recentlyAddressBook]];
    }
    
    [_dataBase close];
}

- (void)casheRecentlyAddressBookWithItem:(AddressBook *)item {
    if (![_dataBase open]) {
        return;
    }
    
    // 将模型通过归档转换成二进制数据
    NSData *modelData = [NSKeyedArchiver archivedDataWithRootObject:item];
    
    FMResultSet *resultSet = [_dataBase executeQuery:[NSString stringWithFormat:@"select * from %@ where id = ?", table_recentlyAddressBook], item.id];
    
    if ([resultSet next]) {
        [_dataBase executeUpdate:[NSString stringWithFormat:@"update %@ set model = ? where id = ?", table_recentlyAddressBook], modelData, item.id];
//        NSLog(@"更新成功");
    }else {
        [_dataBase executeUpdate:[NSString stringWithFormat:@"insert into %@(id, model) values (?, ?)", table_recentlyAddressBook], item.id, modelData];
//        NSLog(@"插入成功");
    }
    
    [_dataBase close];
}

- (NSMutableArray*)getRecentlyAddressBookDataSource {
    if (![_dataBase open])
        return nil;
    
    FMResultSet *resultSet = [_dataBase executeQuery:[NSString stringWithFormat:@"select * from %@", table_recentlyAddressBook]];
    
    NSMutableArray *sourceArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    while ([resultSet next]) {
        // 取出模型数据
        NSData *data = [resultSet dataForColumn:@"model"];
        // 反归档
        AddressBook *item = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        [sourceArray addObject:item];
    }
    
    [_dataBase close];
    
    return sourceArray;
}

#pragma mark - CRM缓存
- (void)creatCRMRecentlyTableWithName:(NSString *)tableName {
    if (!_dataBase) {
        [self creatDatabase];
    }
    
    if (![_dataBase open]) {
        return;
    }
    
    [_dataBase setShouldCacheStatements:YES];
    if (![_dataBase tableExists:[NSString stringWithFormat:@"%@_recently", tableName]]) {
        [_dataBase executeUpdate:[NSString stringWithFormat:@"create table %@_recently(id integer primary key autoincrement, model blob)", tableName]];
    }
    
    [_dataBase close];
}

- (void)casheCRMRecentlyDataSourceWithName:(NSString *)tableName item:(id)obj {
    if (![_dataBase open]) {
        return;
    }
    
    NSNumber *ID;
    if ([obj isKindOfClass:[Lead class]]) {
        Lead *item = obj;
        ID = item.id;
    }
    else if ([obj isKindOfClass:[Customer class]]) {
        Customer *item = obj;
        ID = item.id;
    }
    else if ([obj isKindOfClass:[Contact class]]) {
        Contact *item = obj;
        ID = item.id;
    }
    else if ([obj isKindOfClass:[SaleChance class]]) {
        SaleChance *item = obj;
        ID = item.id;
    }
    
    NSData *modelData = [NSKeyedArchiver archivedDataWithRootObject:obj];
    
    FMResultSet *resultSet = [_dataBase executeQuery:[NSString stringWithFormat:@"select * from %@_recently where id = ?", tableName], ID];
    
    if ([resultSet next]) {
        [_dataBase executeUpdate:[NSString stringWithFormat:@"update %@_recently set model = ? where id = ?", tableName], modelData, ID];
//        NSLog(@"更新成功");
    }else {
        [_dataBase executeUpdate:[NSString stringWithFormat:@"insert into %@_recently(id, model) values (?, ?)", tableName], ID, modelData];
//        NSLog(@"插入成功");
    }
    
    [_dataBase close];
}

- (void)deleteCRMRecentyDataSourceWithName:(NSString *)tableName item:(id)obj {
    if (![_dataBase open]) {
        return;
    }
    
    NSNumber *ID;
    if ([obj isKindOfClass:[Lead class]]) {
        Lead *item = obj;
        ID = item.id;
    }
    else if ([obj isKindOfClass:[Customer class]]) {
        Customer *item = obj;
        ID = item.id;
    }
    else if ([obj isKindOfClass:[Contact class]]) {
        Contact *item = obj;
        ID = item.id;
    }
    else if ([obj isKindOfClass:[SaleChance class]]) {
        SaleChance *item = obj;
        ID = item.id;
    }
    
    [_dataBase executeUpdate:[NSString stringWithFormat:@"delete from %@_recently where id = ?", tableName], ID];
    
    [_dataBase close];
}

- (NSMutableArray*)getCRMRecentlyDataSourceWithName:(NSString *)tableName {
    if (![_dataBase open])
        return nil;
    
    FMResultSet *resultSet = [_dataBase executeQuery:[NSString stringWithFormat:@"select * from %@_recently", tableName]];
    
    NSMutableArray *sourceArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    while ([resultSet next]) {
        // 取出模型数据
        NSData *data = [resultSet dataForColumn:@"model"];
        // 反归档
        if ([tableName isEqualToString:kTableName_lead]) {
            Lead *item = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [sourceArray addObject:item];
        }
        else if ([tableName isEqualToString:kTableName_customer]) {
            Customer *item = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [sourceArray addObject:item];
        }
        else if ([tableName isEqualToString:kTableName_contact]) {
            Contact *item = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [sourceArray addObject:item];
        }
        else if ([tableName isEqualToString:kTableName_opportunity]) {
            SaleChance *item = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [sourceArray addObject:item];
        }
    }
    
    [_dataBase close];
    
    return sourceArray;
}

- (void)createCRMSearchTableWithName:(NSString *)tableName {
    if (!_dataBase) {
        [self creatDatabase];
    }
    
    if (![_dataBase open]) {
        return;
    }
    
    [_dataBase setShouldCacheStatements:YES];
    if (![_dataBase tableExists:[NSString stringWithFormat:@"%@_search", tableName]]) {
        [_dataBase executeUpdate:[NSString stringWithFormat:@"create table %@_search(id integer primary key autoincrement, mId integer, model blob)", tableName]];
    }
    
    [_dataBase close];
}

- (void)casheCRMSearchDataSourceWithTableName:(NSString *)tableName item:(id)obj {
    if (![_dataBase open]) {
        return;
    }
    
    NSNumber *mId;
    if ([obj isKindOfClass:[ActivityModel class]]) {
        ActivityModel *item = obj;
        mId = item.id;
    }
    else if ([obj isKindOfClass:[Lead class]]) {
        Lead *item = obj;
        mId = item.id;
    }
    else if ([obj isKindOfClass:[Customer class]]) {
        Customer *item = obj;
        mId = item.id;
    }
    else if ([obj isKindOfClass:[Contact class]]) {
        Contact *item = obj;
        mId = item.id;
    }
    else if ([obj isKindOfClass:[SaleChance class]]) {
        SaleChance *item = obj;
        mId = item.id;
    }
    
    NSData *modelData = [NSKeyedArchiver archivedDataWithRootObject:obj];
    FMResultSet *resultSet = [_dataBase executeQuery:[NSString stringWithFormat:@"select * from %@_search where mId = ?", tableName], mId];
    if ([resultSet next]) {
        [_dataBase executeUpdate:[NSString stringWithFormat:@"update %@_search set model = ? where mId = ?", tableName], modelData, mId];
//        NSLog(@"更新成功");
    }
    else {
        [_dataBase executeUpdate:[NSString stringWithFormat:@"insert into %@_search(mId, model) values (?, ?)", tableName], mId, modelData];
//        NSLog(@"插入成功");
    }
}

- (BOOL)deleteCRMSearchDataSourceWithTableName:(NSString *)tableName {
    
    if (![_dataBase open]) {
        return NO;
    }
    
    BOOL success =  [_dataBase executeUpdate:[NSString stringWithFormat:@"delete from %@_search", tableName]];
    return success;
}

- (NSMutableArray*)getCRMSearchDataSourceWithTableName:(NSString *)tableName {
    if (![_dataBase open])
        return nil;
    
    FMResultSet *resultSet = [_dataBase executeQuery:[NSString stringWithFormat:@"select * from %@_search", tableName]];
    
    NSMutableArray *sourceArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    while ([resultSet next]) {
        // 取出模型数据
        NSData *data = [resultSet dataForColumn:@"model"];
        // 反归档
        if ([tableName isEqualToString:kTableName_activity]) {
            ActivityModel *item = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [sourceArray addObject:item];
        }
        else if ([tableName isEqualToString:kTableName_lead]) {
            Lead *item = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [sourceArray addObject:item];
        } 
        else if ([tableName isEqualToString:kTableName_customer]) {
            Customer *item = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [sourceArray addObject:item];
        }
        else if ([tableName isEqualToString:kTableName_contact]) {
            Contact *item = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [sourceArray addObject:item];
        }
        else if ([tableName isEqualToString:kTableName_opportunity]) {
            SaleChance *item = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [sourceArray addObject:item];
        }
    }
    
    [_dataBase close];
    
    return sourceArray;
}

- (void)creatCRMTableWithName:(NSString *)tableName {
    if (!_dataBase) {
        [self creatDatabase];
    }
    
    if (![_dataBase open]) {
        return;
    }
    
    [_dataBase setShouldCacheStatements:YES];
    
    if (![_dataBase tableExists:tableName]) {
        [_dataBase executeUpdate:[NSString stringWithFormat:@"create table %@(id integer primary key autoincrement, condition_id integer, sort_id integer, model blob)", tableName]];
    }
    
    [_dataBase close];
}

- (void)casheCRMDataSourceWithName:(NSString *)tableName item:(id)obj conditionId:(NSNumber *)conditionId {
    
}

- (void)casheCRMDataSourceWithName:(NSString *)tableName array:(NSArray *)array conditionId:(NSNumber *)conditionId sortId:(NSNumber *)sortId {
    if (![_dataBase open]) {
        return;
    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
    FMResultSet *resultSet = [_dataBase executeQuery:[NSString stringWithFormat:@"select * from %@ where condition_id = ? and sort_id = ?", tableName], conditionId, sortId];
    if ([resultSet next]) {
        [_dataBase executeUpdate:[NSString stringWithFormat:@"update %@ set model = ? where condition_id = ? and sort_id = ?", tableName], data, conditionId, sortId];
    }else {
        [_dataBase executeUpdate:[NSString stringWithFormat:@"insert into %@(condition_id, sort_id, model) values (?, ?, ?)", tableName], conditionId, sortId, data];
    }
    
    [_dataBase close];
}

- (NSMutableArray*)getCRMDataWithName:(NSString *)tableName conditionId:(NSNumber *)conditionId sortId:(NSNumber *)sortId {
    if (![_dataBase open]) {
        return nil;
    }
    
    FMResultSet *resultSet = [_dataBase executeQuery:[NSString stringWithFormat:@"select * from %@ where condition_id = ? and sort_id = ?", tableName], conditionId, sortId];
    if ([resultSet next]) {
        NSData *data = [resultSet dataForColumn:@"model"];
        return [[NSMutableArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
    }
    [_dataBase close];
    
    return nil;
}

#pragma mark - 工作报告列表
- (void)creatWorkResportWithBaseName:(NSString *)baseName {
    if (!_dataBase) {
        [self creatDatabase];
    }
    if (![_dataBase open]) {
        return;
    }
    [_dataBase setShouldCacheStatements:YES];
    //工作报告
    if (![_dataBase tableExists:baseName]) {
        [_dataBase executeUpdate:[NSString stringWithFormat:@"create table %@ (id integer primary key autoincrement, condition_id integer, sort_id integer, model blob)", baseName]];
    }
    [_dataBase close];
}
- (void)insertOrUpdateDataSourceWithName:(NSString *)tableName array:(NSArray *)array conditionId:(NSNumber *)conditionId sortId:(NSNumber *)sortId {
    if (![_dataBase open]) {
        return;
    }
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
    FMResultSet *resultSet = [_dataBase executeQuery:[NSString stringWithFormat:@"select * from %@ where condition_id = ? and sort_id = ?", tableName], conditionId, sortId];
    if ([resultSet next]) {
        [_dataBase executeUpdate:[NSString stringWithFormat:@"update %@ set model = ? where condition_id = ? and sort_id = ?", tableName], data, conditionId, sortId];
        NSLog(@"更新数据成功");
    }else {
        [_dataBase executeUpdate:[NSString stringWithFormat:@"insert into %@(condition_id, sort_id, model) values (?, ?, ?)", tableName], conditionId, sortId, data];
        NSLog(@"插入数据成功");
    }
    
    [_dataBase close];
}

- (NSMutableArray*)resultDataWithName:(NSString *)tableName conditionId:(NSNumber *)conditionId sortId:(NSNumber *)sortId {
    if (![_dataBase open]) {
        return nil;
    }
    
    FMResultSet *resultSet = [_dataBase executeQuery:[NSString stringWithFormat:@"select * from %@ where condition_id = ? and sort_id = ?", tableName], conditionId, sortId];
    if ([resultSet next]) {
        NSData *data = [resultSet dataForColumn:@"model"];
        NSMutableArray *array = [NSMutableArray arrayWithArray:[[NSMutableArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:data]]];
        return array;
    }
    [_dataBase close];
    return nil;
}
#pragma mark - 工作报告索引
- (void)creatWorkResportIndexPathWithBaseName:(NSString *)baseName {
    if (!_dataBase) {
        [self creatDatabase];
    }
    if (![_dataBase open]) {
        return;
    }
    [_dataBase setShouldCacheStatements:YES];
    //工作报告
    if (![_dataBase tableExists:baseName]) {
        [_dataBase executeUpdate:[NSString stringWithFormat:@"create table %@ (id integer primary key autoincrement, userid text, curIndex integer, fOrder integer)", baseName]];
    }
    [_dataBase close];
}
- (void)insertWorkResportIndexPathWithName:(NSString *)tableName WithUserId:(NSString *)userId WithIndexPathSecation:(NSNumber *)secation WithIndexPathRow:(NSNumber *)row {
    if (![_dataBase open]) {
        return;
    }
    FMResultSet *resultSet = [_dataBase executeQuery:[NSString stringWithFormat:@"select * from %@ where userid = ? ", tableName], userId];
    if ([resultSet next]) {
        [_dataBase executeUpdate:[NSString stringWithFormat:@"update %@ set curIndex = ?, fOrder = ? where userid = ?", tableName], secation, row, userId];
        NSLog(@"更新数据成功");
    }else {
        [_dataBase executeUpdate:[NSString stringWithFormat:@"insert into %@(userid, curIndex, fOrder) values (?, ?, ?)", tableName], userId, secation, row];
        NSLog(@"插入新数据成功");
    }
    [_dataBase close];
}
- (NSDictionary *)resultWorkResportIndexPathWithName:(NSString *)tableName WithUserId:(NSString *)userId {
    if (![_dataBase open]) {
        return nil;
    }
    FMResultSet *resultSet = [_dataBase executeQuery:[NSString stringWithFormat:@"select * from %@ where userid = ?", tableName], userId];
    NSDictionary *dict;
    if ([resultSet next]) {
//        NSData *data = [resultSet dataForColumn:@"model"];
        dict  = @{@"curIndex" : [resultSet stringForColumn:@"curIndex"],
                  @"fOrder" : [resultSet stringForColumn:@"fOrder"]
                  };
    }
    [_dataBase close];
    return dict;

}

//工作报告 审批 选择抄送人
- (void)creatLastContactsAddressBookTable {
    if (!_dataBase) {
        [self creatDatabase];
    }
    
    if (![_dataBase open]) {
        return;
    }
    
    [_dataBase setShouldCacheStatements:YES];
    
    if (![_dataBase tableExists:OA_LASTCONTACTLIST]) {
        [_dataBase executeUpdate:[NSString stringWithFormat:@"create table %@(id integer primary key autoincrement, model blob)", OA_LASTCONTACTLIST]];
    }
    
    [_dataBase close];
}
- (void)insertLastContactsAddressBookWithItem:(AddressBook*)item {
    if (![_dataBase open]) {
        return;
    }
    
    // 将模型通过归档转换成二进制数据
    NSData *modelData = [NSKeyedArchiver archivedDataWithRootObject:item];
    
    FMResultSet *resultSet = [_dataBase executeQuery:[NSString stringWithFormat:@"select * from %@ where id = ?", OA_LASTCONTACTLIST], item.id];
    
    if ([resultSet next]) {
        [_dataBase executeUpdate:[NSString stringWithFormat:@"update %@ set model = ? where id = ?", OA_LASTCONTACTLIST], modelData, item.id];
//        NSLog(@"更新成功");
    }else {
        [_dataBase executeUpdate:[NSString stringWithFormat:@"insert into %@(id, model) values (?, ?)", OA_LASTCONTACTLIST], item.id, modelData];
//        NSLog(@"插入成功");
    }
    
    [_dataBase close];

}
- (NSMutableArray*)getLastContactsAddressBookDataSource {
    if (![_dataBase open])
        return nil;
    
    FMResultSet *resultSet = [_dataBase executeQuery:[NSString stringWithFormat:@"select * from %@", OA_LASTCONTACTLIST]];
    
    NSMutableArray *sourceArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    while ([resultSet next]) {
        // 取出模型数据
        NSData *data = [resultSet dataForColumn:@"model"];
        // 反归档
        AddressBook *item = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        [sourceArray addObject:item];
    }
    
    [_dataBase close];
    
    return sourceArray;
}
- (void)deleteLastContactsAddressBookList {
    if ([_dataBase open]) {
        NSString *sqlStrDelete = [NSString stringWithFormat:@"DELETE FROM %@", OA_LASTCONTACTLIST];
        BOOL resDelete = [_dataBase executeUpdate:sqlStrDelete];
        if (resDelete) {
            NSLog(@"最近联系人清除表成功");
        }else{
            NSLog(@"最近联系人清除表失败");
        }
        [_dataBase close];
    }
}

@end
