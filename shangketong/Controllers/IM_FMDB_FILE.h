//
//  IM_FMDB_FILE.h
//  shangketong
//
//  Created by 蒋 on 15/10/23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB.h>
#import "ContactModel.h"
#import "ConversationListModel.h"
#import "ChatMessage.h"


typedef NS_ENUM(NSInteger, ResultType) {
    ResultTypeContacat = 0, //通讯录
    ResultTypeMessage,  //消息
    ResultTypeGroup   //讨论组
};
@interface IM_FMDB_FILE : NSObject

////置空
+(void)setIM_FMDB_FILE_NULL:(FMDatabase *)sdb;
///关闭数据库
+(void)closeDataBase;
+ (void)removeIM_FMDB;

#pragma mark - 联系人列表（通讯录）
///将通讯录保存到数据库
+(void)getAllAddressBookContactFromServer:(NSArray *)resultArray;
/// 根据返回的联系人status  修改本地缓存数据
/// status 2已激活,3离职,4禁用
+(void)optionAddressByAddressStatus:(NSArray *)arrayAddress;

//插入数据
+ (BOOL)insert_IM_AllAddressBook:(ContactModel *)model;
//更新某个联系人
+ (void)update_IM_OneAddressBook:(ContactModel *)model;
//删除某个联系人
+(void)delete_IM_OneAddressBook:(NSInteger )userId;
//是否有更新
+ (BOOL)isHasOneAddressBook:(NSInteger )userId;
//查询某个联系人
+ (NSMutableArray *)result_IM_AddressBookOneContact:(NSInteger)userId;
//查询所有联系人数据
+ (NSMutableArray *)result_IM_AllContactAddressBook;
//清空缓存
+(void)delete_IM_AllAddressBook;

#pragma mark - 会话列表数据
//插入数据
+ (BOOL)delete_insert_IM_ConversationListWithInfo:(NSArray *)dataSourceArray;
+ (BOOL)insert_IM_ConversationListWithInfo:(ConversationListModel *)model;
//删除会话（会话ID）
+ (void)delete_IM_OneConversationList:(NSString *)groupID;
//清空缓存
+(void)delete_IM_ConversationList;

//修改数据
//修改最后一条消息内容
+ (void)update_IM_ConversationListGroupWithInfo:(NSDictionary *)infoDict;
//修改状态 该讨论组显示与隐藏状态
+ (void)update_IM_ConversationListGroupID:(NSString *)groupId withShow:(NSString *)showString;
//修改已读消息id 和 未读消息数
+ (void)update_IM_ConversationListGroupID:(NSString *)groupId withReadNumber:(NSString *)ReadNumber withUnReadNumber:(NSString *)UnReadNumber;
+ (NSInteger)result_IM_One_ConversationUnReadnumber:(NSString *)groupId;
//添加草稿类型
+ (void)update_IM_ConversationListGroupID:(NSString *)groupId withUnsendSting:(NSString *)unSendString;

//查询数据
+ (NSMutableArray *)result_IM_ConversationListWithResultType:(NSString *)resultType;
//查询会话人数据
+ (NSMutableArray *)result_IM_UsersListOfGroupType:(NSString *)groupType;



#pragma mark - 消息（聊天内容）列表展示
//插入数据
+ (BOOL)insert_IM_MessageListGroupID:(NSString *)groupId withMessageId:(NSString *)messageId withInfo:(NSString *)messageString withMessageState:(MessageState)state;
//删除消息
+ (void)delete_IM_MessageListGroupID:(NSString *)groupId withMessageId:(NSString *)messageId;
//清空缓存 Message
+(void)delete_IM_OneGroupMessageList:(NSString *)groupId;
//清空缓存所有聊天缓存
+(void)delete_IM_AllGroupMessageList;
//修改消息
+ (void)update_IM_MessageListGroupID:(NSString *)groupId withMessageId:(NSString *)messageId WithNewMessageId:(NSString *)newMessageId withInfo:(NSString *)messageString;
//修改消息状态
+ (void)update_IM_MessageListGroupID:(NSString *)groupId withMessageId:(NSString *)messageId WithMessageState:(MessageState)state;
//查询数据
+ (NSMutableArray *)result_IM_MessageList:(NSString *)groupId;
//查询全部聊天记录数据
+ (NSMutableArray *)result_IM_AllGroup_MessageList;

#pragma mark - 缓存每个讨论组中已读到的最后一条消息
+ (BOOL)insert_IM_LastMessageOfOneGroup:(NSString *)groupId withMessgeId:(NSString *)messageId;
+ (void)delete_IM_LastMessageOfOneGroup:(NSString *)groupId;
+ (void)delete_IM_LastMessageList;
+ (NSString *)result_IM_LastMessageId:(NSString *)groupId;

#pragma mark - 谈论组中的联系人
//插入会话人
+ (BOOL)insert_IM_UsersListListGroupID:(NSString *)groupId withGroupType:(NSString *)type withInfo:(ContactModel *)model;
//删除会话人
+(void)delete_IM_UsersListListGroupID:(NSString *)groupId;
//查询会话人数据
+ (NSMutableArray *)result_IM_UserList:(NSString *)groupId;
//删除讨论组某一个联系人
+ (void)delete_IM_OneUsersListListGroupID:(NSString *)groupId WithContactId:(NSInteger)contactId;
#pragma mark - 最近联系人 Recent contact
//插入最近联系人
+ (BOOL)insert_IM_RecentContact:(ContactModel *)model;
//删除最近联系人
+(void)delete_IM_RecentContact:(NSString *)userID;
//清除最近联系人表
+(void)delete_IM_AllRecentContact;
//查询最近联系人数据
+ (NSMutableArray *)result_IM_RecentContactList;

#pragma mark - 讨论组是否显示成员昵称
+ (BOOL)insert_IM_ShowOrHiddenContactName:(NSString *)groupId withShow:(NSString *)showStr;
+ (void)delete_IM_ShowOrHiddenContactName:(NSString *)groupId;
+ (NSString *)result_IM_ShowOrHiddenContactName:(NSString *)groupId;


#pragma mark - 批量操作
+(void)batch_option_im:(NSArray *)array;
//是否需要先删除消息再进行存储
+ (void)deleteOneMessage:(NSString *)groupId value:(void(^)(BOOL isDelete, NSString *messageId))value;
+ (NSMutableArray *)batch_result_IM:(NSArray *)array withType:(ResultType)type;
@end
