//
//  GBMoudle.h
//  shangketong
//
//  Created by sungoin-zjp on 15-5-21.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CWStatusBarNotification.h"
#import "StatusBarMsgView.h"

///cell类型
typedef NS_ENUM(NSInteger, WorkGroupType) {
    ///主动发布的动态
    ///可以点赞、收藏/取消收藏、转发、评论、删除
    WorkGroupTypeA = 0,
    ///完成任务的动态：可以评论、删除
    ///活动记录的动态：可以评论、删除
    WorkGroupTypeB,
    ///业务数据的动态：不能进行任何操作
    WorkGroupTypeC,
    ///转发的动态  只能评论和赞操作
    WorkGroupTypeD,
    ///评论与赞操作
    WorkGroupTypeE
};

///cell状态
typedef NS_ENUM(NSInteger, WorkGroupTypeStatus) {
    ///cell
    WorkGroupTypeStatusCell = 0,
    ///详情
    WorkGroupTypeStatusDetails,
};


///viewcontroller 当前标记
typedef NS_ENUM(NSInteger, CurShowViewController) {
    ///市场活动
    CampaignViewCtr = 0,
    ///销售线索
    SalesOpportunityViewCtr,
};


@interface GBMoudle : NSObject

#warning 需缓存的数据

///市场活动-statusNames
@property(strong,nonatomic) NSMutableArray *arrayCampaignsStatusNames;

///公海池- statusNames
@property(strong,nonatomic) NSMutableArray *arrayHighSeaStatusStatusNames;

///销售线索- statusNames
@property(strong,nonatomic) NSMutableArray *arraySaleLeadtatusStatusNames;


#warning 临时数据
@property(strong,nonatomic)  NSString *userId;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userCompanyId;
@property (nonatomic, strong) NSString *IM_tokenString; // IM  http请求需要传token

@property (copy, nonatomic) NSString *userFunctionCodes;    // 用户权限
@property (assign, nonatomic) NSInteger isOpen_cluePool;    // 线索池是否开启
@property (assign, nonatomic) NSInteger isOpen_customerPool;// 客户池是否开启

///通讯录信息
//@property(strong,nonatomic) NSMutableArray *arrayAllAddressBook;
///部门缓存
@property(strong,nonatomic) NSMutableArray *arrayAllDepartment;
///群组缓存
@property(strong,nonatomic) NSMutableArray *arrayAllGroup;
///日程筛选类型
@property(strong,nonatomic) NSArray *arrayScheduleColorType;
///日程首页  从服务器获取到本月有日程任务的时期
@property (nonatomic, strong) NSMutableArray *arrayScheduleAndTask;


#pragma mark - 动态相关缓存数据 
///我关注的动态 公开动态 我的收藏 我的动态
///路径
@property (nonatomic, strong) NSString *filepath_user_focus_dynamic;
@property (nonatomic, strong) NSString *filepath_user_public_dynamic;
@property (nonatomic, strong) NSString *filepath_user_favorite_dynamic;
@property (nonatomic, strong) NSString *filepath_user_my_dynamic;
///数据
@property(strong,nonatomic) NSMutableArray *user_focus_dynamic;
@property(strong,nonatomic) NSMutableArray *user_public_dynamic;
@property(strong,nonatomic) NSMutableArray *user_favorite_dynamic;
@property(strong,nonatomic) NSMutableArray *user_my_dynamic;

#pragma mark -- 全局变量，本次登陆有效。用来存储全部工作报告和全部审批显示权限
@property (nonatomic, assign) BOOL isShowAll;


#pragma mark -- TabBar 消息提醒小点图片
@property(nonatomic, strong)UIImageView* icon_unread_skt;
@property(nonatomic, strong)UIImageView* icon_unread_im;
@property(nonatomic, strong)UIImageView* icon_unread_crm;
@property(nonatomic, strong)UIImageView* icon_unread_oa;
@property(nonatomic, strong)UIImageView* icon_unread_me;


#pragma mark - 标记当前viewcontroller
@property(nonatomic, strong)UIViewController *controllerCurView;

#pragma mark - 标记喜报弹框是否已经显示
@property (nonatomic, assign) BOOL isVictoryShowAlready;

#pragma mark - 标记IM页面  用来做IM消息提示的区分
@property (nonatomic, assign) BOOL isIMView;
///是否点击了消息页面
@property (nonatomic, assign) BOOL isLoadIMView;

///是否是临时账户
@property(nonatomic, assign) BOOL isTmpAccount;

///是否显示图片预览view
@property (nonatomic, assign) BOOL isShowPhotoView;


#pragma mark - 未读消息数标记 总未读消息数=待办提醒+通知+公告+企业微信的未读消息数
///工作报告、审批、日程、任务
//@property (nonatomic, assign) NSInteger numberUnReadOA;
/// 待办提醒 + 通知 + 公告
@property (nonatomic, assign) NSInteger numberUnReadIMNotice;
/// 企业微信
@property (nonatomic, assign) NSInteger numberUnReadMessage;


#pragma mark - 最新动态信息
@property (nonatomic, strong) NSString *icon_oa_workzone_newtrends;

///系统公告弹框
@property(nonatomic, strong)UIAlertView *alertViewOfSysAnnouncement;


#pragma mark - IM消息自定义弹框
@property(nonatomic, strong) CWStatusBarNotification *notificationIM;
@property(nonatomic, strong) StatusBarMsgView *viewStatusBarIM;
@end
