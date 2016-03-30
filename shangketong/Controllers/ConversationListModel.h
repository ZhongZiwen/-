//
//  ConversationListModel.h
//  shangketong
//
//  Created by 蒋 on 15/10/13.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ConversationListType) {
    ConversationListText         = 0,    // 文字
    ConversationListImage        = 1,    // 图片
    ConversationListVoice        = 3,    // 语音
    ConversationListInformation  = 5     // 提示信息
};

@interface ConversationListModel : NSObject
//b_代表body层 u_代表userViewList层  m_代表messageView层 r_代表resourceView层
/*  数据层次结构
body:{
    userViewList:{
        
    },
    messageView:{
 
        resourceView:{
            
        }
 
    }
}
 */
@property (nonatomic, assign) BOOL isShow; //删除后，控制显示不显示该讨论组

@property (nonatomic, strong) NSString *b_id; //会话id
@property (nonatomic, strong) NSString *b_name; //会话名称
@property (nonatomic, strong) NSString *b_remark; //描述
@property (nonatomic, strong) NSString *b_type; //会话类型 0两个人 1讨论组
@property (nonatomic, strong) NSString *b_msgNumber; //读到的消息id（暂时没用）
@property (nonatomic, strong) NSString *b_userId;  // 所属用户id
@property (nonatomic, strong) NSString *b_count; //参与会话人数
@property (nonatomic, strong) NSString *b_createDate; //创建时间
@property (nonatomic, strong) NSString *b_unReadNumber; //未读消息数
@property (nonatomic, strong) NSString *b_modify;   //是否修改过讨论组名称
@property (nonatomic, assign) long long b_versionCode; //版本号

@property (nonatomic, strong) NSString *u_id; //用户id
@property (nonatomic, strong) NSString *u_weixin; //用户微信号
@property (nonatomic, strong) NSString *u_mobile; //手机号
@property (nonatomic, strong) NSString *u_phone; //电话(分机，固话)号
@property (nonatomic, strong) NSString *u_email; //用户邮箱
@property (nonatomic, strong) NSString *u_name; //姓名
@property (nonatomic, strong) NSString *u_position; //职务
@property (nonatomic, strong) NSString *u_images; //头像
@property (nonatomic, strong) NSString *u_type; //外部1 内部0

@property (nonatomic, strong) NSString *m_id; //消息id
@property (nonatomic, strong) NSString *m_userId; //发送消息人的id
@property (nonatomic, strong) NSString *m_content; //消息内容
@property (nonatomic, strong) NSString *m_type; //消息类型 消息类 system: 0系统消息  text: 1文本类型  create: 2创建组 join: 3加入组 exit: 4退出组  update:5修改组
@property (nonatomic, strong) NSString *m_time; //发送消息时间
@property (nonatomic, strong) NSString *m_lastMessageTime; //最后一条消息的时间
@property (nonatomic, strong) NSString *m_groupId; //所属组id
@property (nonatomic, strong) NSString *m_number; //序号
// resourceView  资源结构（根据消息类型决定是否存在）
@property (nonatomic, assign) BOOL isHave; //是否有数据
@property (nonatomic, strong) NSString *r_id; //资源id
@property (nonatomic, strong) NSString *r_name; //资源名称
@property (nonatomic, strong) NSString *r_fileName; //资源保存路径
@property (nonatomic, strong) NSString *r_type; //类型img: 1// 图片类型   file: 2,// 文件类型  voice: 3// 语音类型
@property (nonatomic, strong) NSString *r_size; //大小
@property (nonatomic, strong) NSString *r_second; //语音的秒数

@property (nonatomic, strong) NSMutableArray *imgsArray; //用户头像
@property (nonatomic, assign) ConversationListType message_type;//消息类型

@property (nonatomic, strong) NSMutableArray *messageListArray;
@property (nonatomic, strong) NSMutableArray *usersListArray; //讨论组成员


- (ConversationListModel *)initWithDictionary:(NSDictionary *)dict;
+ (ConversationListModel *)initWithDictionary:(NSDictionary *)dict;

@end
