//
//  RemindModel.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/29.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

//代办提醒
typedef NS_ENUM(NSInteger, RemindType) {
    RemindTypeSchedule      = 1,           // 日程
    RemindTypeTask          = 2,           // 任务
    RemindTypeApproval      = 3,           // 审批
    RemindTypeWorkreportDay    = 4,           // 日报
    RemindTypeWorkreportWeek    = 5,           // 周报
    RemindTypeWorkreportMonth    = 6,           // 月报
    
};
//系统公告 1动态；2博客；3文档；4日程；5任务；6审批；7粉丝； 8群组.
typedef NS_ENUM(NSInteger, NoticeType) {
    NoticeTypeRecord = 1,
    NoticeTypeBlog = 2,
    NoticeTypeFile = 3,
    NoticeTypeSchedule = 4,
    NoticeTypeTask = 5,
    NoticeTypeApproval = 6,
    NoticeTypeInfo = 7,
    NoticeTypeGroup = 8
};
@interface RemindModel : NSObject

@property (nonatomic, copy) NSString *user_name;    // 用户名
@property (nonatomic, copy) NSString *user_uid;     // 用户id
@property (nonatomic, copy) NSString *user_icon;    // 用户头像

@property (nonatomic, copy) NSString *m_content;    // 提醒内容
@property (nonatomic, copy) NSString *m_operate;    // 进入详情操作id
@property (nonatomic, copy) NSString *m_createdTime;// 创建时间
@property (nonatomic, assign) RemindType m_type;    // 提醒类别
@property (nonatomic, assign) NoticeType m_noticeType; //系统公告提醒类别
@property (nonatomic, strong) NSString *isRead;  //已读、未读
@property (nonatomic, strong) NSString *remindID;
@property (nonatomic, assign) NSInteger dataId;
- (RemindModel*)initWithDictionary:(NSDictionary*)dict;
+ (RemindModel*)initWithDictionary:(NSDictionary*)dict;
@end
