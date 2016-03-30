//
//  IM_FMDB_FILE.m
//  shangketong
//
//  Created by 蒋 on 15/10/23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "IM_FMDB_FILE.h"
#import "NSUserDefaults_Cache.h"

static FMDatabase *shareDataBase = nil;
static NSString *const fmdbFilePath = @"IM_FMDB_FILE.sqlite";
static NSString *const conversationList = @"CONVERSATIONLIST";
static NSString *const messageList = @"MESSAGELIST";
static NSString *const usersList = @"USERSLIST";
static NSString *const recentContactList = @"RECENTCONTACTLIST";
static NSString *const lastMessageList = @"LASTMESSAGELIST";
static NSString *const showContactNameList = @"SHOWCONTACTNAMELIST";
static NSString *const lastContactList = @"LASTCONTACTLIST";
static NSString *const addressBookList = @"ADDRESSBOOKLIST";

@implementation IM_FMDB_FILE
//建表
+(FMDatabase *)createDatabase {
    //安全锁
    @synchronized(self){
        if (!shareDataBase) {
            NSDictionary *userInfo = [NSUserDefaults_Cache getUserInfo];
            NSString *userId = [userInfo safeObjectForKey:@"id"];
            NSString *fmdbPath = [NSString stringWithFormat:@"%@_%@_%@", userId, userId, fmdbFilePath];
            shareDataBase = [FMDatabase databaseWithPath:[self filePaths:fmdbPath]];
            NSLog(@"IM数据路径%@", fmdbPath);
            if (![shareDataBase open]) {
                NSLog(@"数据打开失败");
            } else {
                //会话列表
                NSString *sqlStrConversationList = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(groupId text, show bit, createDate text, msgNumber text, name text, type text, unReadNumber text, content text, number text, time text, msgType text, userid text, isHave bit, r_type text, messageTime text)", conversationList];
                [shareDataBase executeUpdate:sqlStrConversationList];
                //消息列表
                NSString *sqlStrMessageList = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(id text, messageId text, message text, show bit, messageState INTEGER)", messageList];
                [shareDataBase executeUpdate:sqlStrMessageList];
                
                //讨论组中最后一条消息
                NSString *sqlStrLastMessageList = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(groupId text, messageId text)", lastMessageList];
                [shareDataBase executeUpdate:sqlStrLastMessageList];
                
                //讨论组成员列表
                NSString *sqlStrUsersList = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(id text, name text, images text, u_id INTEGER, groupType text)", usersList];
                [shareDataBase executeUpdate:sqlStrUsersList];
                
                //最近联系人
                NSString *sqlStrRecentContactList = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(id text, u_name text, image text, u_depart text, u_position text, u_flag INTEGER)", recentContactList];
                [shareDataBase executeUpdate:sqlStrRecentContactList];
                
                //讨论组是否显示昵称
                NSString *sqlStrShowContactName = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(id text, show text)", showContactNameList];
                [shareDataBase executeUpdate:sqlStrShowContactName];
                
                //最近联系人 departmentName positionName
//                NSString *sqlStrLastContactList = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(id text, name text, images text, department text, position text)", lastContactList];
//                [shareDataBase executeUpdate:sqlStrLastContactList];
                
                //联系人列表（通讯录）
                NSString *sqlStrAddressBookList = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(id INTEGER, name text, images text, department text, position text, state INTEGER)", addressBookList];
                [shareDataBase executeUpdate:sqlStrAddressBookList];
            }
        }
    }
    return shareDataBase;
}
//置空
+ (void)setIM_FMDB_FILE_NULL:(FMDatabase *)sdb {
    shareDataBase = sdb;
}
//关闭数据库
+ (void)closeDataBase {
    if (![shareDataBase close]) {
        NSLog(@"数据关闭异常");
        return;
    }
}
//路径
+ (NSString*) filePaths:(NSString*)fileName
{
    NSString* documentDirectory = [NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString* _filePath = [documentDirectory stringByAppendingPathComponent:fileName];
    
    return _filePath;
}
+ (void)removeIM_FMDB {
    BOOL success;
    NSError *error;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // delete the old db.
    if ([fileManager fileExistsAtPath:[FMDBManagement databaseFilePath]]) {
        [shareDataBase close];
        shareDataBase = nil;
        success = [fileManager removeItemAtPath:[FMDBManagement databaseFilePath] error:&error];
        if (!success) {
            NSAssert1(0, @"Failed to delete old database file with message '%@'.", [error localizedDescription]);
        }
    }

}
#pragma mark - 联系人列表（通讯录）
+(void)getAllAddressBookContactFromServer:(NSArray *)resultArray {
    NSInteger count = 0;
    if (resultArray ) {
        count = [resultArray count];
    }
    NSMutableArray *insertArray = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i < count; i ++) {
        NSDictionary *dict = [resultArray objectAtIndex:i];
        ContactModel *item = [ContactModel initWithDataSource:dict];
        NSString *sqlStr = [NSString stringWithFormat:@"insert into %@(id, name, images, department, position, state) values ('%ld', '%@', '%@' ,'%@', '%@', '%ld')", addressBookList, item.userID, item.contactName, item.imgHeaderName, item.departmentName, item.positionName, item.state];
        [insertArray addObject:sqlStr];
    }
    if (insertArray.count > 0) {
        [IM_FMDB_FILE batch_option_im:insertArray];
    }
    
}
+(void)optionAddressByAddressStatus:(NSArray *)arrayAddress {
    NSInteger count = 0;
    if (arrayAddress) {
        count = [arrayAddress count];
    }
    
    NSInteger status = 0;
    for (int i=0; i<count; i++) {
        status = [[[arrayAddress objectAtIndex:i] safeObjectForKey:@"status"] integerValue];
#warning 匹配讨论组成员，IM中通讯录不做删除成员处理
        ///新增
//        if (status == 2) {
            NSLog(@"有新增联系人");
            ContactModel *item = [ContactModel initWithDataSource:[arrayAddress objectAtIndex:i]];
            ///如果存在 则更新
            if ([IM_FMDB_FILE isHasOneAddressBook:item.userID]) {
                [IM_FMDB_FILE update_IM_OneAddressBook:item];
                NSLog(@"");
            }else{
                ///不存在 插入
                [IM_FMDB_FILE insert_IM_AllAddressBook:item];
            }
//        }else if (status == 3 || status == 4) {
//            NSLog(@"有禁用联系人");
//            ///从缓存里删除
//            [IM_FMDB_FILE delete_IM_OneAddressBook:[[[arrayAddress objectAtIndex:i] safeObjectForKey:@"id"] integerValue]];
//        } else {
//            
//        }
    }
}
//插入数据
+ (BOOL)insert_IM_AllAddressBook:(ContactModel *)model {
    BOOL isSuccessful = NO;
    shareDataBase = [IM_FMDB_FILE createDatabase];
    if ([shareDataBase open]) {
        NSString *sqlStr = [NSString stringWithFormat:@"insert into %@(id, name, images, department, position, state) values ('%ld', '%@', '%@' ,'%@', '%@', '%ld')", addressBookList, model.userID, model.contactName, model.imgHeaderName, model.departmentName, model.positionName, model.state];
        isSuccessful = [shareDataBase executeUpdate:sqlStr];
        if (isSuccessful) {
//            NSLog(@"联系人插入数据成功");
        }else{
//            NSLog(@"联系人插入数据失败");
        }
        [shareDataBase close];
    }
    return isSuccessful;
}
//更新某个联系人
+ (void)update_IM_OneAddressBook:(ContactModel *)model {
    shareDataBase = [IM_FMDB_FILE createDatabase];
    if ([shareDataBase open]) {
        NSString *sqlStr = [NSString stringWithFormat:@"UPDATE %@ SET name = '%@', images = '%@', department = '%@', position = '%@', state = '%ld' WHERE id = '%ld'", addressBookList, model.contactName, model.imgHeaderName, model.departmentName, model.positionName, model.state ,model.userID];
        BOOL res = [shareDataBase executeUpdate:sqlStr];
        if (res) {
            NSLog(@"修改成功");
        }else{
            NSLog(@"修改失败");
        }
        [shareDataBase close];
    }
    
}
//是否有更新
+ (BOOL)isHasOneAddressBook:(NSInteger )userId {
    BOOL isExist = FALSE;
    shareDataBase = [IM_FMDB_FILE createDatabase];
    if ([shareDataBase open]) {
        NSString *sqlStr = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE  id = '%ti'", addressBookList,userId];
        FMResultSet *resultSet = [shareDataBase executeQuery:sqlStr];
        if ([resultSet next]) {
            if ([resultSet intForColumn:@"id"]) {
                isExist = TRUE;
//                NSLog(@"联系人存在id:%i  name:%@",[resultSet intForColumn:@"id"],[resultSet stringForColumn:@"name"]);
            }
        }else{
            isExist = FALSE;
//            NSLog(@"联系人不存在");
        }
    }
    return isExist;
}
//删除某个联系人
+(void)delete_IM_OneAddressBook:(NSInteger )userId {
    shareDataBase = [IM_FMDB_FILE createDatabase];
    if ([shareDataBase open]) {
        NSString *sqlStr = [NSString stringWithFormat:@"DELETE FROM %@ WHERE id = '%ld'", addressBookList,userId];
        BOOL res = [shareDataBase executeUpdate:sqlStr];
        if (res) {
            NSLog(@"删除成功");
        }else{
            NSLog(@"删除失败");
        }
        [shareDataBase close];
    }
}
+ (NSMutableArray *)result_IM_AddressBookOneContact:(NSInteger)userId {
    NSString *sqlStr = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE id = '%ld'", addressBookList, userId];
    NSMutableArray *infoArray = [NSMutableArray array];
    shareDataBase = [IM_FMDB_FILE createDatabase];
    if ([shareDataBase open]) {
        FMResultSet *resultSet = [shareDataBase executeQuery:sqlStr];
        while([resultSet next]) {
            ContactModel *model = [[ContactModel alloc] init];
            model.userID = [resultSet intForColumn:@"id"];
            model.contactName = [resultSet stringForColumn:@"name"];
            model.imgHeaderName = [resultSet stringForColumn:@"images"];
            model.departmentName = [resultSet stringForColumn:@"department"];
            model.positionName = [resultSet stringForColumn:@"position"];
            model.state = [resultSet intForColumn:@"state"];
            [infoArray addObject:model];
        }
        [shareDataBase close];
    }
    return infoArray;
    
}
//查询所有联系人数据
+ (NSMutableArray *)result_IM_AllContactAddressBook {
    NSString *sqlStr = [NSString stringWithFormat:@"SELECT * FROM %@", addressBookList];
    NSMutableArray *infoArray = [NSMutableArray array];
    shareDataBase = [IM_FMDB_FILE createDatabase];
    if ([shareDataBase open]) {
        FMResultSet *resultSet = [shareDataBase executeQuery:sqlStr];
        while([resultSet next]) {
            ContactModel *model = [[ContactModel alloc] init];
            model.userID = [resultSet intForColumn:@"id"];
            model.contactName = [resultSet stringForColumn:@"name"];
            model.imgHeaderName = [resultSet stringForColumn:@"images"];
            model.departmentName = [resultSet stringForColumn:@"department"];
            model.positionName = [resultSet stringForColumn:@"position"];
            model.state = [resultSet intForColumn:@"state"];
            if (model.state != 3 && model.state != 4) {
                [infoArray addObject:model];
            }
        }
        [shareDataBase close];
    }
    return infoArray;
}
//清空缓存
+(void)delete_IM_AllAddressBook {
    shareDataBase = [IM_FMDB_FILE createDatabase];
    if ([shareDataBase open]) {
        NSString *sqlstrDelete = [NSString stringWithFormat:@"DELETE FROM %@", addressBookList];
        BOOL resDelete = [shareDataBase executeUpdate:sqlstrDelete];
        if (resDelete) {
            NSLog(@"清除表成功");
        }else{
            NSLog(@"清除表失败");
        }
    }
}


#pragma mark - 会话列表
+ (BOOL)delete_insert_IM_ConversationListWithInfo:(NSArray *)dataSourceArray {
    BOOL isSuccessful = NO;
    shareDataBase = [IM_FMDB_FILE createDatabase];
    if ([shareDataBase open]) {
        for (NSDictionary *dict in dataSourceArray) {
            ConversationListModel *model = [[ConversationListModel alloc] initWithDictionary:dict];
            NSString *sqlStr = [NSString stringWithFormat:@"insert into %@(groupId, show, createDate, msgNumber, name, type, unReadNumber, content, number, time, msgType, userid, isHave, r_type, messageTime) values ('%@', '%d', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%d', '%@', '%@')", conversationList, model.b_id, 1, model.b_createDate, model.b_msgNumber, model.b_name, model.b_type, model.b_unReadNumber, model.m_content, model.m_number, model.m_time, model.m_type, model.m_userId, model.isHave, model.r_type, model.m_lastMessageTime];
            isSuccessful = [shareDataBase executeUpdate:sqlStr];
            if (isSuccessful) {
                NSLog(@"会话列表插入数据成功");
            }else{
                NSLog(@"会话列表插入数据失败");
            }
        }
        
//        [shareDataBase close];
    }
    return isSuccessful;
}


#pragma mark - 会话列表
+ (BOOL)insert_IM_ConversationListWithInfo:(ConversationListModel *)model {
    BOOL isSuccessful = NO;
    shareDataBase = [IM_FMDB_FILE createDatabase];
    if ([shareDataBase open]) {
        NSString *sqlStr = [NSString stringWithFormat:@"insert into %@(groupId, show, createDate, msgNumber, name, type, unReadNumber, content, number, time, msgType, userid, isHave, r_type, messageTime) values ('%@', '%d', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%d', '%@', '%@')", conversationList, model.b_id, 1, model.b_createDate, model.b_msgNumber, model.b_name, model.b_type, model.b_unReadNumber, model.m_content, model.m_number, model.m_time, model.m_type, model.m_userId, model.isHave, model.r_type, model.m_lastMessageTime];
        isSuccessful = [shareDataBase executeUpdate:sqlStr];
        if (isSuccessful) {
            NSLog(@"会话列表插入数据成功");
        }else{
            NSLog(@"会话列表插入数据失败");
        }
        [shareDataBase close];
    }
    return isSuccessful;
}
+ (void)delete_IM_OneConversationList:(NSString *)groupID {
    shareDataBase = [IM_FMDB_FILE createDatabase];
    if ([shareDataBase open]) {
        NSString *sqlStrDelete = [NSString stringWithFormat:@"DELETE FROM %@ WHERE groupId = '%@'", conversationList, groupID];
        BOOL resDelete = [shareDataBase executeUpdate:sqlStrDelete];
        if (resDelete) {
            NSLog(@"会话列表删除数据成功");
        } else {
            NSLog(@"会话列表删除数据失败");
        }
        [shareDataBase close];
    }
}
///删除所有数据缓存
+(void)delete_IM_ConversationList{
    shareDataBase = [IM_FMDB_FILE createDatabase];
    if ([shareDataBase open]) {
        NSString *sqlStrDelete = [NSString stringWithFormat:@"DELETE FROM %@", conversationList];
        BOOL resDelete = [shareDataBase executeUpdate:sqlStrDelete];
        if (resDelete) {
            NSLog(@"会话列表清除表成功");
        }else{
            NSLog(@"会话列表清除表失败");
        }
        [shareDataBase close];
    }
}
+ (void)update_IM_ConversationListGroupWithInfo:(NSDictionary *)infoDict {
    shareDataBase = [IM_FMDB_FILE createDatabase];
    if ([shareDataBase open]) {
        NSString *sqlStrUpdate = [NSString stringWithFormat:@"UPDATE %@ SET content = '%@', number = '%@', msgType = '%@', userid = '%@', isHave = '%ld', r_type = '%@', messageTime = '%@' , time = '%@'WHERE groupId = '%@'", conversationList, [infoDict objectForKey:@"content"], [infoDict objectForKey:@"number"], [infoDict objectForKey:@"type"], [infoDict objectForKey:@"userId"],[[infoDict objectForKey:@"isHave"] integerValue], [infoDict objectForKey:@"r_type"], [infoDict objectForKey:@"time"], [infoDict objectForKey:@"sendTime"], [infoDict objectForKey:@"id"]];
        BOOL resUpdate = [shareDataBase executeUpdate:sqlStrUpdate];
        if (resUpdate) {
            NSLog(@"会话列表修改数据成功");
        } else {
            NSLog(@"会话列表修改数据失败");
        }
        [shareDataBase close];
    }
}
+ (void)update_IM_ConversationListGroupID:(NSString *)groupId withShow:(NSString *)showString {
    shareDataBase = [IM_FMDB_FILE createDatabase];
    if ([shareDataBase open]) {
        NSString *sqlStrUpdate = [NSString stringWithFormat:@"UPDATE %@ SET show = '%ld' WHERE groupId = '%@'", conversationList, [showString integerValue], groupId];
        BOOL resUpdate = [shareDataBase executeUpdate:sqlStrUpdate];
        if (resUpdate) {
            NSLog(@"会话列表修改数据成功");
        } else {
            NSLog(@"会话列表修改数据失败");
        }
        [shareDataBase close];
    }
}
+ (void)update_IM_ConversationListGroupID:(NSString *)groupId withReadNumber:(NSString *)ReadNumber withUnReadNumber:(NSString *)UnReadNumber {
    shareDataBase = [IM_FMDB_FILE createDatabase];
    if ([shareDataBase open]) {
        NSString *sqlStrUpdate = [NSString stringWithFormat:@"UPDATE %@ SET msgNumber = '%@', unReadNumber = '%@' WHERE groupId = '%@'", conversationList, ReadNumber, UnReadNumber, groupId];
        BOOL resUpdate = [shareDataBase executeUpdate:sqlStrUpdate];
        if (resUpdate) {
            NSLog(@"会话列表修改数据成功");
        } else {
            NSLog(@"会话列表修改数据失败");
        }
        [shareDataBase close];
    }
}

+ (void)update_IM_ConversationListGroupID:(NSString *)groupId withUnsendSting:(NSString *)unSendString {
    shareDataBase = [IM_FMDB_FILE createDatabase];
    if ([shareDataBase open]) {
        NSString *sqlStrUpdate = [NSString stringWithFormat:@"UPDATE %@ SET content = '%@' WHERE groupId = '%@'", conversationList, unSendString, groupId];
        BOOL resUpdate = [shareDataBase executeUpdate:sqlStrUpdate];
        if (resUpdate) {
            NSLog(@"会话列表修改数据成功");
        } else {
            NSLog(@"会话列表修改数据失败");
        }
        [shareDataBase close];
    }
}
+ (NSInteger)result_IM_One_ConversationUnReadnumber:(NSString *)groupId {
    NSString *sqlStr = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE groupId = '%@'", conversationList, groupId];
    shareDataBase = [IM_FMDB_FILE createDatabase];
    NSInteger unReadnumber = 0;
    if ([shareDataBase open]) {
        FMResultSet *resultSet = [shareDataBase executeQuery:sqlStr];
        while([resultSet next]) {
            unReadnumber = [[resultSet stringForColumn:@"unReadNumber"] integerValue];
        }
    }
    return unReadnumber;
}
+ (NSMutableArray *)result_IM_ConversationListWithResultType:(NSString *)resultType {
    NSString *sqlStr = [NSString stringWithFormat:@"SELECT * FROM %@", conversationList];
    NSMutableArray *infoArray = [NSMutableArray array];
    shareDataBase = [IM_FMDB_FILE createDatabase];
    if ([shareDataBase open]) {
        FMResultSet *resultSet = [shareDataBase executeQuery:sqlStr];
        while([resultSet next]) {
            // groupId text, show bit, createDate text, msgNumber INTEGER, name text, type INTEGER, unReadNumber INTEGER, content text, number INTEGER, time text, type INTEGER, userid INTEGER
            ConversationListModel *model = [[ConversationListModel alloc] init];
            model.b_createDate = [resultSet stringForColumn:@"createDate"];
            model.b_msgNumber = [resultSet stringForColumn:@"msgNumber"];
            model.b_name = [resultSet stringForColumn:@"name"];
            model.b_type = [resultSet stringForColumn:@"type"];
            model.m_content = [resultSet stringForColumn:@"content"];
            model.m_number = [resultSet stringForColumn:@"number"];
            model.m_time = [resultSet stringForColumn:@"time"];
            model.m_lastMessageTime = [resultSet stringForColumn:@"messageTime"];
            model.m_type = [resultSet stringForColumn:@"msgType"];
            model.m_userId = [resultSet stringForColumn:@"userid"];
            model.isShow = [[resultSet stringForColumn:@"show"] boolValue];
            model.b_id = [resultSet stringForColumn:@"groupId"];
            model.isHave = [[resultSet stringForColumn:@"isHave"] boolValue];
            model.r_type = [resultSet stringForColumn:@"r_type"];
            model.b_unReadNumber = [resultSet stringForColumn:@"unReadNumber"];
            if ([resultType isEqualToString:@"result"]) {
                [infoArray addObject:model];
            } else {
                if (model.isShow) {
                    [infoArray addObject:model];
                }
            }
        }
        [shareDataBase close];
    }
    return infoArray;
}

//获取两人会话或者讨论组全部id
+ (NSMutableArray *)result_IM_UsersListOfGroupType:(NSString *)groupType {
    NSString *sqlStr = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE type = '%@'", conversationList, groupType];
    NSMutableArray *infoArray = [NSMutableArray array];
    shareDataBase = [IM_FMDB_FILE createDatabase];
    if ([shareDataBase open]) {
        FMResultSet *resultSet = [shareDataBase executeQuery:sqlStr];
        while([resultSet next]) {
            NSString *groupId = [resultSet stringForColumn:@"groupId"];
            [infoArray addObject:groupId];
        }
        [shareDataBase close];
    }
    return infoArray;
}

#pragma mark - 消息（聊天内容）列表展示
//插入数据
+ (BOOL)insert_IM_MessageListGroupID:(NSString *)groupId withMessageId:(NSString *)messageId withInfo:(NSString *)messageString withMessageState:(MessageState)state {
    BOOL isSuccessful = NO;
    shareDataBase = [IM_FMDB_FILE createDatabase];
    if ([shareDataBase open]) {
        NSString *sqlStrInsert = [NSString stringWithFormat:@"insert into %@ (id, messageId, message, messageState) values ('%@', '%@', '%@', '%ld')", messageList, groupId, messageId, messageString, state];
        isSuccessful = [shareDataBase executeUpdate:sqlStrInsert];
        if (isSuccessful) {
            NSLog(@"聊天消息插入数据成功");
        } else {
            NSLog(@"聊天消息插入数据失败");
        }
        [shareDataBase close];
    }
    return isSuccessful;
}
//删除消息
+ (void)delete_IM_MessageListGroupID:(NSString *)groupId  withMessageId:(NSString *)messageId {
    shareDataBase = [IM_FMDB_FILE createDatabase];
    if ([shareDataBase open]) {
        NSString *sqlStrDelete = [NSString stringWithFormat:@"DELETE FROM %@ WHERE id = '%@' AND messageId = '%@'", messageList, groupId ,messageId];
        BOOL resDelete = [shareDataBase executeUpdate:sqlStrDelete];
        if (resDelete) {
            NSLog(@"聊天消息删除数据成功");
        } else {
            NSLog(@"聊天消息删除数据失败");
        }
        [shareDataBase close];
    }
    
}
//清空缓存 Message
+(void)delete_IM_OneGroupMessageList:(NSString *)groupId {
    shareDataBase = [IM_FMDB_FILE createDatabase];
    if ([shareDataBase open]) {
        NSString *sqlStrDelete = [NSString stringWithFormat:@"DELETE FROM %@ WHERE id = '%@'", messageList, groupId];
        BOOL resDelete = [shareDataBase executeUpdate:sqlStrDelete];
        if (resDelete) {
            NSLog(@"聊天消息清除表成功");
        }else{
            NSLog(@"聊天消息清除表失败");
        }
        [shareDataBase close];
    }
}
//清空缓存所有聊天缓存
+(void)delete_IM_AllGroupMessageList {
    shareDataBase = [IM_FMDB_FILE createDatabase];
    if ([shareDataBase open]) {
        NSString *sqlStrDelete = [NSString stringWithFormat:@"DELETE FROM %@", messageList];
        BOOL resDelete = [shareDataBase executeUpdate:sqlStrDelete];
        if (resDelete) {
            NSLog(@"清除所有聊天信息成功");
        }else{
            NSLog(@"清除所有聊天消息失败");
        }
        [shareDataBase close];
    }
}
//修改消息
+ (void)update_IM_MessageListGroupID:(NSString *)groupId withMessageId:(NSString *)messageId WithNewMessageId:(NSString *)newMessageId withInfo:(NSString *)messageString {
    shareDataBase = [IM_FMDB_FILE createDatabase];
    if ([shareDataBase open]) {
        NSString *sqlStrUpdate = [NSString stringWithFormat:@"UPDATE %@ SET messageId = '%@', message = '%@' WHERE id = '%@' AND messageId = '%@'", messageList, newMessageId, messageString, groupId,messageId];
        BOOL resUpdate = [shareDataBase executeUpdate:sqlStrUpdate];
        if (resUpdate) {
            NSLog(@"修改某条消息成功");
        } else {
            NSLog(@"修改某条消息失败");
        }
    [shareDataBase close];
    }
}
//修改消息状态
+ (void)update_IM_MessageListGroupID:(NSString *)groupId withMessageId:(NSString *)messageId WithMessageState:(MessageState)state {
    shareDataBase = [IM_FMDB_FILE createDatabase];
    if ([shareDataBase open]) {
        NSString *sqlStrUpdate = [NSString stringWithFormat:@"UPDATE %@ SET messageState = '%ld' WHERE id = '%@' AND messageId = '%@'", messageList, state, groupId,messageId];
        BOOL resUpdate = [shareDataBase executeUpdate:sqlStrUpdate];
        if (resUpdate) {
            NSLog(@"修改自己发送消息状态成功");
        } else {
            NSLog(@"修改自己发送消息状态失败");
        }
        [shareDataBase close];
    }
}
//查询数据
+ (NSMutableArray *)result_IM_MessageList:(NSString *)groupId {
    NSString *sqlStr = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE id = '%@'", messageList, groupId];
    NSMutableArray *infoArray = [NSMutableArray array];
    shareDataBase = [IM_FMDB_FILE createDatabase];
    if ([shareDataBase open]) {
        FMResultSet *resultSet = [shareDataBase executeQuery:sqlStr];
        while([resultSet next]) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            NSString *infoSring = [resultSet stringForColumn:@"message"];
            MessageState msgState = [resultSet intForColumn:@"messageState"];
            [dict setObject:infoSring forKey:@"message"];
            [dict setObject:@(msgState) forKey:@"messageState"];
            [infoArray addObject:dict];
        }
        [shareDataBase close];
    }
    return infoArray;
}
//查询全部聊天记录数据
+ (NSMutableArray *)result_IM_AllGroup_MessageList {
    NSString *sqlStr = [NSString stringWithFormat:@"SELECT * FROM %@ ", messageList];
    NSMutableArray *infoArray = [NSMutableArray array];
    shareDataBase = [IM_FMDB_FILE createDatabase];
    if ([shareDataBase open]) {
        FMResultSet *resultSet = [shareDataBase executeQuery:sqlStr];
        while([resultSet next]) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            NSString *infoSring = [resultSet stringForColumn:@"message"];
            MessageState msgState = [resultSet intForColumn:@"messageState"];
            NSString *groupId = [resultSet stringForColumn:@"id"];
            [dict setObject:infoSring forKey:@"message"];
            [dict setObject:@(msgState) forKey:@"messageState"];
            [dict setObject:groupId forKey:@"groupId"];
            [infoArray addObject:dict];
        }
        [shareDataBase close];
    }
    return infoArray;
}

#pragma mark - 缓存每个讨论组中已读到的最后一条消息
+ (BOOL)insert_IM_LastMessageOfOneGroup:(NSString *)groupId withMessgeId:(NSString *)messageId {
    BOOL isSucessful = NO;
    shareDataBase = [IM_FMDB_FILE createDatabase];
    if ([shareDataBase open]) {
        NSString *sqlStr = [NSString stringWithFormat:@"insert into %@(groupId, messageId) values ('%@', '%@')", lastMessageList, groupId, messageId];
        isSucessful = [shareDataBase executeUpdate:sqlStr];
        if (isSucessful) {
            NSLog(@"插入最后一条消息信息成功");
        } else {
            NSLog(@"插入最后一条消息信息失败");
        }
        [shareDataBase close];
    }
    return isSucessful;
}
+ (void)delete_IM_LastMessageOfOneGroup:(NSString *)groupId {
    if ([shareDataBase open]) {
        NSString *sqlStrDelete = [NSString stringWithFormat:@"DELETE FROM %@ WHERE groupId = '%@'", lastMessageList, groupId];
        BOOL resDelete = [shareDataBase executeUpdate:sqlStrDelete];
        if (resDelete) {
            NSLog(@"删除最后一条消息信息成功");
        } else {
            NSLog(@"删除最后一条消息信息失败");
        }
        [shareDataBase close];
    }
}
+ (void)delete_IM_LastMessageList {
    if ([shareDataBase open]) {
        NSString *sqlStrDelete = [NSString stringWithFormat:@"DELETE FROM %@", lastMessageList];
        BOOL resDelete = [shareDataBase executeUpdate:sqlStrDelete];
        if (resDelete) {
            NSLog(@"清除最后一条消息表成功");
        } else {
            NSLog(@"清除最后一条消息表成功");
        }
        [shareDataBase close];
    }
}
+ (NSString *)result_IM_LastMessageId:(NSString *)groupId {
    NSString *sqlStr = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE groupId = '%@'", lastMessageList, groupId];
    NSString *messgeId = @"";
    shareDataBase = [IM_FMDB_FILE createDatabase];
    if ([shareDataBase open]) {
        FMResultSet *resultSet = [shareDataBase executeQuery:sqlStr];
        while([resultSet next]) {
            messgeId = [resultSet stringForColumn:@"messageId"];
        }
        [shareDataBase close];
    }
    if ([messgeId isEqualToString:@"(null)"] || [messgeId isEqualToString:@""]) {
        messgeId = @"0";
    }
    return messgeId;
}
#pragma mark - 谈论组中的联系人
//插入会话人
+ (BOOL)insert_IM_UsersListListGroupID:(NSString *)groupId withGroupType:(NSString *)type withInfo:(ContactModel *)model {
    BOOL isSuccessful = NO;
    shareDataBase = [IM_FMDB_FILE createDatabase];
    if ([shareDataBase open]) {
        NSString *sqlStr = [NSString stringWithFormat:@"insert into %@(id, name, images, u_id, groupType) values ('%@', '%@', '%@', '%ld', '%@')", usersList, groupId, model.contactName, model.imgHeaderName, model.userID, type];
        isSuccessful = [shareDataBase executeUpdate:sqlStr];
        if (isSuccessful) {
            NSLog(@"会话人插入数据成功");
        }else{
            NSLog(@"会话人插入数据失败");
        }
//        [shareDataBase close];
    }
    return isSuccessful;
}
//删除会话人
+(void)delete_IM_UsersListListGroupID:(NSString *)groupId {
    if ([shareDataBase open]) {
        NSString *sqlStrDelete = [NSString stringWithFormat:@"DELETE FROM %@ WHERE id = '%@'", usersList, groupId];
        BOOL resDelete = [shareDataBase executeUpdate:sqlStrDelete];
        if (resDelete) {
            NSLog(@"会话人清除表成功");
        }else{
            NSLog(@"会话人清除表失败");
        }
        [shareDataBase close];
    }
}
//查询某个组的会话人数据
+ (NSMutableArray *)result_IM_UserList:(NSString *)groupId {
    NSString *sqlStr = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE id = '%@'", usersList, groupId];
    NSMutableArray *infoArray = [NSMutableArray array];
    shareDataBase = [IM_FMDB_FILE createDatabase];
    if ([shareDataBase open]) {
        FMResultSet *resultSet = [shareDataBase executeQuery:sqlStr];
        while([resultSet next]) {
            ContactModel *model = [[ContactModel alloc] init];
            model.contactName = [resultSet stringForColumn:@"name"];
            model.imgHeaderName = [resultSet stringForColumn:@"images"];
            model.userID = [[resultSet stringForColumn:@"u_id"] integerValue];
            [infoArray addObject:model];
        }
        [shareDataBase close];
    }
    return infoArray;
}
//删除讨论组某一个联系人
+ (void)delete_IM_OneUsersListListGroupID:(NSString *)groupId WithContactId:(NSInteger)contactId {
    if ([shareDataBase open]) {
        NSString *sqlStrDelete = [NSString stringWithFormat:@"DELETE FROM %@ WHERE id = '%@' AND u_id = '%ld'", usersList, groupId, contactId];
        BOOL resDelete = [shareDataBase executeUpdate:sqlStrDelete];
        if (resDelete) {
            NSLog(@"会话人清除表成功");
        }else{
            NSLog(@"会话人清除表失败");
        }
         [shareDataBase close];
    }
}

#pragma mark - 最近联系人 Recent contact
//插入最近联系人
+ (BOOL)insert_IM_RecentContact:(ContactModel *)model {
    BOOL isSuccessful = NO;
    shareDataBase = [IM_FMDB_FILE createDatabase];
    if ([shareDataBase open]) {
        NSString *sqlStr = [NSString stringWithFormat:@"insert into %@(id, u_name, image, u_depart, u_position, u_flag) values ('%@', '%@', '%@' ,'%@', '%@', '%ti')", recentContactList, [NSString stringWithFormat:@"%ld", model.userID], model.contactName, model.imgHeaderName, model.departmentName, model.positionName, model.originIndex];
        isSuccessful = [shareDataBase executeUpdate:sqlStr];
        if (isSuccessful) {
            NSLog(@"最近联系人插入数据成功");
        }else{
            NSLog(@"最近联系人插入数据失败");
        }
        [shareDataBase close];
    }
    return isSuccessful;
}
//删除最近联系人
+(void)delete_IM_RecentContact:(NSString *)userID {
    if ([shareDataBase open]) {
        NSString *sqlStrDelete = [NSString stringWithFormat:@"DELETE FROM %@ WHERE id = '%@'", recentContactList, userID];
        BOOL resDelete = [shareDataBase executeUpdate:sqlStrDelete];
        if (resDelete) {
            NSLog(@"最近联系人清除表成功");
        }else{
            NSLog(@"最近联系人清除表失败");
        }
        [shareDataBase close];
    }
    
}
//清除最近联系人表
+(void)delete_IM_AllRecentContact {
    if ([shareDataBase open]) {
        NSString *sqlStrDelete = [NSString stringWithFormat:@"DELETE FROM %@", recentContactList];
        BOOL resDelete = [shareDataBase executeUpdate:sqlStrDelete];
        if (resDelete) {
            NSLog(@"最近联系人清除表成功");
        }else{
            NSLog(@"最近联系人清除表失败");
        }
        [shareDataBase close];
    }
}
//查询最近联系人数据
+ (NSMutableArray *)result_IM_RecentContactList {
    NSString *sqlStr = [NSString stringWithFormat:@"SELECT * FROM %@", recentContactList];
    NSMutableArray *infoArray = [NSMutableArray array];
    shareDataBase = [IM_FMDB_FILE createDatabase];
    if ([shareDataBase open]) {
        FMResultSet *resultSet = [shareDataBase executeQuery:sqlStr];
        while([resultSet next]) {
            ContactModel *model = [[ContactModel alloc] init];
            model.userID = [[resultSet stringForColumn:@"id"] integerValue];
            model.contactName = [resultSet stringForColumn:@"u_name"];
            model.imgHeaderName = [resultSet stringForColumn:@"image"];
            model.departmentName = [resultSet stringForColumn:@"u_depart"];
            model.positionName = [resultSet stringForColumn:@"u_position"];
            model.originIndex = [[resultSet stringForColumn:@"u_flag"] integerValue];
            [infoArray addObject:model];
        }
        [shareDataBase close];
    }
    return infoArray;
}

#pragma mark - 讨论组是否显示成员昵称
+ (BOOL)insert_IM_ShowOrHiddenContactName:(NSString *)groupId withShow:(NSString *)showStr {
    BOOL isSuccessful = NO;
    shareDataBase = [IM_FMDB_FILE createDatabase];
    if ([shareDataBase open]) {
        NSString *sqlStr = [NSString stringWithFormat:@"insert into %@(id, show) values ('%@', '%@')", showContactNameList, groupId, showStr];
        isSuccessful = [shareDataBase executeUpdate:sqlStr];
        if (isSuccessful) {
            NSLog(@"讨论组是否显示成员昵称插入数据成功");
        }else{
            NSLog(@"讨论组是否显示成员昵称插入数据失败");
        }
        [shareDataBase close];
    }
    return isSuccessful;
}
+ (void)delete_IM_ShowOrHiddenContactName:(NSString *)groupId {
    if ([shareDataBase open]) {
        NSString *sqlStrDelete = [NSString stringWithFormat:@"DELETE FROM %@ WHERE id = '%@'", showContactNameList, groupId];
        BOOL resDelete = [shareDataBase executeUpdate:sqlStrDelete];
        if (resDelete) {
            NSLog(@"最近联系人清除表成功");
        }else{
            NSLog(@"最近联系人清除表失败");
        }
        [shareDataBase close];
    }

}
+ (NSString *)result_IM_ShowOrHiddenContactName:(NSString *)groupId {
    NSString *sqlStr = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE id = '%@'", showContactNameList, groupId];
    NSString *showStr = @"";
    shareDataBase = [IM_FMDB_FILE createDatabase];
    if ([shareDataBase open]) {
        FMResultSet *resultSet = [shareDataBase executeQuery:sqlStr];
        while([resultSet next]) {
            showStr = [resultSet stringForColumn:@"show"];
        }
        [shareDataBase close];
    }
    return showStr;
}




#pragma mark - 批量操作
+(void)batch_option_im:(NSArray *)array{
    
    //    dispatch_async(dispatch_queue_create("batch updation queue", NULL), ^{
    shareDataBase = [IM_FMDB_FILE createDatabase];
//    NSLog(@"sql数量：%lu", (unsigned long)array.count);
    
    if ([shareDataBase open]) {
        
        ///一定要使用缓存，时间复杂度减小10倍！
        [shareDataBase shouldCacheStatements];
        
        NSDate *date = [NSDate date];
        NSLog(@"启动事务");
        //开始启动事务
        [shareDataBase beginTransaction];
        
        NSLog(@"开始逐条SQL更新");
        [array enumerateObjectsUsingBlock:^(NSString *sql, NSUInteger idx, BOOL *stop) {
//            NSLog(@"当前执行第%lu条sql: %@", (unsigned long)idx, sql);
            BOOL res = [shareDataBase executeUpdate:sql];
            if (!res) {
//                NSLog(@"error when update db table");
            } else {
//                NSLog(@"success to update db table");
            }
            //                        [array removeObject:sql];
            //                        [sqls addObject:sql];
        }];
        
        
        //提交事务
        if([shareDataBase commit]) {
            NSLog(@"提交事务成功");
        }
        else {
            NSLog(@"提交事务失败");
        }
        
        //关闭数据库
        if (![shareDataBase close]) {
            NSLog(@"![db2 close]");
            return;
        }
        float interval = [[NSDate date] timeIntervalSinceDate:date];
        NSLog(@"总耗时：%f", interval);
        
    }
}

//是否需要先删除消息再进行存储
+ (void)deleteOneMessage:(NSString *)groupId value:(void(^)(BOOL isDelete, NSString *messageId))value {
    NSArray *array = [NSArray arrayWithArray:[IM_FMDB_FILE result_IM_MessageList:groupId]];
    NSInteger count = [array count];
    NSLog(@"%s %ld", __FUNCTION__, count);
    NSString *msgId = @"";
    if (array > 0) {
        NSDictionary *dict = [NSDictionary dictionaryWithDictionary:[CommonFuntion dictionaryWithJsonString:array[0][@"message"]]];
        msgId = [dict safeObjectForKey:@"id"];
    }
    if (count < 30) {
        value(NO, msgId);
    } else {
        value(YES,msgId);
    }
}
+ (NSMutableArray *)batch_result_IM:(NSArray *)array withType:(ResultType)type {
    NSMutableArray *allResult = [NSMutableArray arrayWithCapacity:0];
    shareDataBase = [IM_FMDB_FILE createDatabase];
    NSLog(@"sql数量：%lu", (unsigned long)array.count);
    
    if ([shareDataBase open]) {
        
        ///一定要使用缓存，时间复杂度减小10倍！
        [shareDataBase shouldCacheStatements];
        
        NSDate *date = [NSDate date];
        NSLog(@"启动事务");
        //开始启动事务
        [shareDataBase beginTransaction];
        
        NSLog(@"开始逐条SQL更新");
        [array enumerateObjectsUsingBlock:^(NSString *sql, NSUInteger idx, BOOL *stop) {
            //            NSLog(@"当前执行第%lu条sql: %@", (unsigned long)idx, sql);
            FMResultSet *resultSet = [shareDataBase executeQuery:sql];
                while([resultSet next]) {
                    switch (type) {
                        case 0:
                        {
                            ContactModel *model = [[ContactModel alloc] init];
                            model.userID = [resultSet intForColumn:@"id"];
                            model.contactName = [resultSet stringForColumn:@"name"];
                            model.imgHeaderName = [resultSet stringForColumn:@"images"];
                            model.departmentName = [resultSet stringForColumn:@"department"];
                            model.positionName = [resultSet stringForColumn:@"position"];
                            model.state = [resultSet intForColumn:@"state"];
                            [allResult addObject:model];
                        }
                            break;
                        case 1:
                        {
                            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                            NSString *infoSring = [resultSet stringForColumn:@"message"];
                            MessageState msgState = [resultSet intForColumn:@"messageState"];
                            [dict setObject:infoSring forKey:@"message"];
                            [dict setObject:@(msgState) forKey:@"messageState"];
                            [allResult addObject:dict];

                        }
                            break;
                        case 2:
                        {
                            
                        }
                            break;
                            
                        default:
                            break;
                    }
                }
        }];
        
        
        //提交事务
        if([shareDataBase commit]) {
            NSLog(@"提交事务成功");
        }
        else {
            NSLog(@"提交事务失败");
        }
        
        //关闭数据库
        if (![shareDataBase close]) {
            NSLog(@"![db2 close]");
            //            return allResult;
        }
        float interval = [[NSDate date] timeIntervalSinceDate:date];
        NSLog(@"总耗时：%f", interval);
    }
    return allResult;
}
@end
