//
//  ChatMessage.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/27.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ChatMessageType) {
    ChatMessageTypeImage         = 1,    //图片
    ChatMessageTypeFile        = 2,    //文件
    ChatMessageTypeVoice        = 3,    // 语音
};
typedef NS_ENUM(NSInteger, MessageState) {
    MessageStateSend = 1, //发送中
    MessageStateRecevied = 2, //发送成功
    MessageStateFail = 3 //发送失败
};
/*
消息类型system: 0,// 系统消息   
text: 1,// 文本类型
create: 2,// 创建组
join: 3,// 加入组
exit: 4, // 退出组
update:5 // 修改组
 */

@interface ChatMessage : NSObject

@property (nonatomic, assign) BOOL isSelect; //是否被选中（cell）
@property (nonatomic, assign) MessageState msg_state; //消息状态
@property (nonatomic, assign) ChatMessageType msg_type;     // 消息类型（ResourceView层）
@property (nonatomic, strong)  NSString *msg_id;             // 消息id
@property (nonatomic, copy) NSString *msg_time;             // 消息时间
@property (nonatomic, assign) BOOL isMe;
@property (nonatomic, strong) NSString *msg_number;   //消息number
@property (nonatomic, copy) NSString *type; //消息类型（MessageView层）
@property (nonatomic, assign) BOOL hasResourceView;
@property (nonatomic, assign) NSInteger msg_uid;

@property (nonatomic, copy) NSString *user_uid;
@property (nonatomic, copy) NSString *user_icon;
@property (nonatomic, copy) NSString *user_name;

// ChatMessageTypeText || ChatMessageTypeInformation
@property (nonatomic, copy) NSString *msg_content;          // 消息内容

// ChatMessageTypeImage
@property (nonatomic, copy) NSString *msg_imageUrl;
@property (nonatomic, copy) NSString *msg_imageSUrl;
@property (nonatomic, copy) NSString *msg_imageLUrl;
@property (nonatomic, assign) NSInteger msg_imageWidth;
@property (nonatomic, assign) NSInteger msg_imageHeight;
@property (nonatomic, copy) NSString *msg_imageName;

// ChatMessageTypeVoice
@property (nonatomic, copy) NSString *msg_voiceUrl;
@property (nonatomic, assign) NSInteger msg_voiceDuration;  // 录音时间
@property (nonatomic, copy) NSString *msg_voiceName; //语音文件名
@property (nonatomic, assign) BOOL isRead; //是否已读，语音

// ChatMessageTypeFile
@property (nonatomic, strong) NSString *msg_fileUrl;
@property (nonatomic, strong) NSString *msg_fileName;
@property (nonatomic, strong) NSString *msg_fileSize;

- (ChatMessage*)initWithDictionary:(NSDictionary*)dict withNSArray:(NSArray *)usersArray;
+ (ChatMessage*)initWithDictionary:(NSDictionary*)dict withNSArray:(NSArray *)usersArray;
@end
