//
//  AFNHttp.h
//  shangketong
//
//  Created by sungoin-zjp on 15-1-19.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#pragma mark- 接口action

////---------环境配置------------///

// APP环境
#define SKT_SERVER_IP @"http://app.sunke.com"
#define SKT_P @"user"
#define SKT_SOCKET_SERVER_IP @"ws://im.sunke.com/im/websocket"
#define SKT_IM_SERVER_IP @"http://im.sunke.com/im"
#define SKT_PORT @""
#define HTTPURL_IM_IMG_VOICE [NSString stringWithFormat:@"%@/upload/",SKT_IM_SERVER_IP]


///120测试环境
//#define SKT_SERVER_IP @"http://192.168.1.120"
//#define SKT_P @"skt-user"
//#define SKT_SOCKET_SERVER_IP @"ws://192.168.1.120/skt-im/websocket"
//#define SKT_IM_SERVER_IP @"http://192.168.1.120/skt-im"
//#define SKT_PORT @":8080"
//#define HTTPURL_IM_IMG_VOICE @"http://192.168.1.120/skt-im/upload/"


//#define SKT_SERVER_IP @"http://192.168.4.151"
//#define SKT_P @"user"
//#define SKT_SOCKET_SERVER_IP @"ws://192.168.4.151/skt-im/websocket"
//#define SKT_IM_SERVER_IP @"http://192.168.4.151/skt-im"
//#define SKT_PORT @":9080"
//#define HTTPURL_IM_IMG_VOICE @"http://192.168.4.151/skt-im/upload/"

// UAT环境
//#define SKT_SERVER_IP @"http://uat.sunke.com"
//#define SKT_P @"user"
//#define SKT_SOCKET_SERVER_IP @"ws://im.sunke.com/im/websocket"
//#define SKT_IM_SERVER_IP @"http://im.sunke.com/im"
//#define SKT_PORT @""
//#define HTTPURL_IM_IMG_VOICE [NSString stringWithFormat:@"%@/upload/",SKT_IM_SERVER_IP]


///小陈磊
//#define SKT_SERVER_IP @"http://192.168.4.151"
//#define SKT_P @"user"
//#define SKT_PORT @":8087"

//林祥浩本地
//#define SKT_SERVER_IP @"http://192.168.4.149"
//#define SKT_P @"skt_user"
//#define SKT_SOCKET_SERVER_IP @"ws://192.168.4.149:8081/skt_im/websocket"
//#define SKT_IM_SERVER_IP @"http://192.168.4.149:8081/skt_im"
//#define SKT_PORT @":8081"
//#define HTTPURL_IM_IMG_VOICE [NSString stringWithFormat:@"%@/upload/",SKT_IM_SERVER_IP]



///版本code
#define SKT_VERSION_CODE  @"302"
///测试版本号
#define BETA_NO @""

///友盟
#define SKT_UMENG_KEY @"5684a59867e58e5d5e000cc1"

///AppStore地址
#define SKT_URL_APPATORE @"https://itunes.apple.com/cn/app/shang-ke-tong/id908677026?l=zh&ls=1&mt=8"

///---------------------代码重复 只需留一份---------------------///

/// code  1
#define WEB_SERVER_IP     [NSString stringWithFormat:@"%@%@/%@/",SKT_SERVER_IP,SKT_PORT,SKT_P]
#define MOBILE_SERVER_IP  [NSString stringWithFormat:@"%@%@/%@/mobile/",SKT_SERVER_IP,SKT_PORT,SKT_P]
#define MOBILE_SERVER_IP_OA  [NSString stringWithFormat:@"%@%@/%@/oa/",SKT_SERVER_IP,SKT_PORT,SKT_P]
#define MOBILE_SERVER_IP_CRM [NSString stringWithFormat:@"%@%@/%@/crm/",SKT_SERVER_IP,SKT_PORT,SKT_P]
//IM  http://im.sunke.com/im/    http://uat.sunke.com/user/
#define MOBILE_SERVER_IP_IM [NSString stringWithFormat:@"%@/user/",SKT_IM_SERVER_IP]

//个人信息
#define MOBILE_SERVER_IP_ADMIN  [NSString stringWithFormat:@"%@%@/%@/admin/",SKT_SERVER_IP,SKT_PORT,SKT_P]


/// code  2
// 登录、选择公司
#define kNetPath_Web_Server_Base  [NSString stringWithFormat:@"%@%@/%@/",SKT_SERVER_IP,SKT_PORT,SKT_P]
// crm
#define kNetPath_Crm_Server_Base  [NSString stringWithFormat:@"%@%@/%@/crm/",SKT_SERVER_IP,SKT_PORT,SKT_P]
// oa
#define kNetPath_Oa_Server_Base  [NSString stringWithFormat:@"%@%@/%@/oa/",SKT_SERVER_IP,SKT_PORT,SKT_P]
// admin 个人信息相关和评论相关的 /user开头的
#define kNetPath_Admin_Server_Base  [NSString stringWithFormat:@"%@%@/%@/admin/",SKT_SERVER_IP,SKT_PORT,SKT_P]
//user
#define kNetPath_User_Server_Base  [NSString stringWithFormat:@"%@%@/%@/user/",SKT_SERVER_IP,SKT_PORT,SKT_P]

///---------------------代码重复 只需留一份---------------------///



#pragma mark - 登录
#define LOGIN_ACTION @"j_spring_security_check"
#define LOGOUT_ACTION @"j_spring_security_logout"


#pragma mark - 办公模块权限控制接口
///  oa列表权限显示接口
#define OA_PREMISSION @"my-oa-list.do"


#pragma mark - 通讯录
///通讯录列表
#define ADDRESS_BOOK_ACTION @"address-book/contact-list.do"
///通讯录部门列表
#define ADDRESS_BOOK_CHILD_DEPARTMENT_ACTION @"address-book/child-departments-list.do"
//所在部门以及部门下的子部门（发布动态---选择一个部门）
#define ADDRESS_BOOK_DEPARAMENT_AND_ALL_CHILD_ACTION @"address-book/child-department.do"
///通讯录群组列表
#define ADDRESS_BOOK_GROUP_ACTION @"address-book/group-list.do"
///部门员工 参数 departmentId
#define DEPARTMENT_CHILD_STAFFS_ACTION @"address-book/child-staffs-list.do"
///群组员工 参数 groupId
#define GROUP_STAFFS_ACTION @"address-book/group-staff-list.do"
///关注  参数 contactId
#define ADD_FOLLOW_ACTION @"address-book/add_follow.do"
///取消关注  参数 contactId
#define CANCEL_FOLLOW_ACTION @"address-book/cancel_follow.do"

#pragma mark - 联系人资料
///获取联系人资料   uid（自己的话，不用传入）
#define GET_CONTACT_INFO_ACTION @"user/show-contact-info.do"
///更新联系人资料   name（名字）,post（职位）,email(没有验证的话传入),mobile(没有验证的话传入),phone（电话）,extension（分机）,intro（个人介绍）,expertise（特长）,userIcon（头像）
#define UPDATE_CONTACT_INFO_ACTION @"user/update-myself.do"


#pragma mark -切换公司
///参数 tenantId
#define CHANGE_COMPANY_ACTION @"user/chooseCompany.do"

#pragma mark - 意见反馈 admin
#define FEED_BACK_ACTION @"feedBack/addFeddBack.do"// content反馈的内容

///举报接口
#define REPORT_TO_SERVICE_ACTION @"feedBack/report.do"



#pragma mark - 全部工作报告 全部审批 (oa)
#define ALL_REPORT_AND_APPROVE @"user/isAllAuthority.do"

#pragma mark - 工作报告
///我提交的报告
#define MY_REPORT_LIST @"work-report/my-report-list.do"
///提交给我的报告
#define REPORT_TO_ME_LIST @"work-report/report-to-me-list.do"
///全部报告
#define REPORT_ALL_LIST @"work-report/report-all-list.do"
///报告详情
#define REPORT_DETAILS @"work-report/report-detail.do"

// 新建报告
#define REPORT_CREATE @"work-report/open-create-report.do"
// 工作报告汇总
#define REPORT_WORK_RESULT @"work-report/work-result.do"
// 单个批阅
#define kNetPath_Report_Approve @"work-report/approve-report.do"
// 全部批阅
#define kNetPath_Report_ApproveAll @"work-report/approve-all-report.do"


// 提交工作报告
#define kNetPath_Report_Submit @"work-report/submit-report.do"
// 保存草稿
#define kNetPath_Report_SavePaper @"work-report/save-paper-report.do"
// 删除报告
#define kNetPath_Report_Delete @"work-report/delete.do"
// 获取工作报告筛选条件
#define kNetPath_Report_Filter @"work-report/get-filter.do"


#pragma mark - 我的动态
///我的动态列表 pageNo （第几页）
#define MY_TRENDS_LIST @"dynamic/my-trends-list.do"

///获取动态列表
///参数：type(类型(company(公开动态)/dept(部门)/group(群组)/focus(我关注的)),groupId(组ID,type为dept时传入),deptId(部门ID,type为group时传入)
#define TRENDS_LIST @"dynamic/trends-list.do"

///删除动态  trendsId （动态ID）
#define DELETE_DYNAMIC @"dynamic/deleteDynamic.do"

///赞操作 trendsId （动态ID）
#define FEED_UP_ADD @"dynamic/feed-up-add.do"

///我的收藏列表 pageNo （第几页）
#define MY_FAVORITES_LIST @"dynamic/Favorites-list.do"
///收藏  trendsId
#define ADD_FAVORITE @"dynamic/addFavorite.do"
///取消收藏  trendsId
#define DELETE_FAVORITE @"dynamic/deleteFavorite.do"
///获取评论列表 参数：trendsId（动态ID）  pageNo（第几页）
#define TREND_DETAILS_COMMENT_LIST @"comment/comment-list.do"
///添加一条评论  参数：trendsId（动态ID） content（评论内容） staffIds（@人id集合,以“,”分隔开）objectType
///(类型<1：动态 2：博客 3：知识库  4:任务 5:工作报告>) ，评论接口改了，你们看下，加了个参数
#define TREND_ADD_A_COMMENT @"comment/add-comment.do"
///删除评论  ,objectType (类型<1：动态 2：博客 3：知识库  4:日程 5:任务 6:日报 7:周报 8:月报 9:审批>)
#define TREND_DELETE_A_COMMENT @"comment/deleteComment.do"

///发表动态  参数：files(图片),content(动态内容),staffIds(@人id集合,以“,”分隔开),warnType(部门或者群组类型,必传,默认传入1),warnId(部门或者群组ID),
#define TREND_ADD_A_DYNAMIC @"dynamic/add-dynamic.do"

///转发  参数：trendsId(动态ID),content(转发理由),staffIds(@人id集合,以“,”分隔开),warnType(部门或者群组类型,必传,默认传入1),warnId(部门或者群组ID)
#define TREND_FORWARD_A_DYNAMIC @"dynamic/feed-forward.do"

///通知使用详情接口
///动态详情
#define TREND_DETAILS_A_DYNAMIC @"dynamic/getDynamicDetail.do"
///博客详情   只返回 blogTitle 和content
#define TREND_DETAILS_A_BLOG @"dynamic/getBlogDetail.do"


#pragma mark - 审批
// 获取提交给我的审批
#define kNetPath_Approve_Mine @"examine-approve/my-application-list.do"
// 获取提交给我的审批
#define kNetPath_Approve_ToMe @"examine-approve/my-approval-list.do"
// 获取所有的审批
#define kNetPath_Approve_All @"examine-approve/all-approval-list.do"
// 获取审批类型
#define kNetPath_Approve_Type @"examine-approve/examine-order-type.do"
// 根据审批类型id 获取审批流程
#define kNetPath_Approve_Flow @"examine-approve/examine-order-flow.do"
// 新建审批申请 初始化申请条件
#define kNetPath_Approve_Application @"examine-approve/init-application.do"
// 审批类型筛选
#define kNetPath_Approve_Filter @"examine-approve/get-filter.do"
// 审批详情
#define kNetPath_Approve_Detail @"examine-approve/get-application-detail.do"
// 提交审批
#define kNetPath_Approve_Submit @"examine-approve/submit-my-application.do"
// 撤回审批
#define kNetPath_Approve_Reback @"examine-approve/reback.do"
// 删除审批
#define kNetPath_Approve_Delete @"examine-approve/delete.do"
// 同意审批
#define kNetPath_Approve_Agree @"examine-approve/agree.do"
// 拒绝审批
#define kNetPath_Approve_Refuse @"examine-approve/refuse.do"


#pragma mark - 日程
// 日程详情
#define kNetPath_Schedule_Info @"schedule/get-scheduleInfo.do"
// 获取日程筛选类型
#define kNetPath_Schedule_ColorType @"schedule/get-color-type.do"
// 修改日程
#define kNetPath_Schedule_Update @"schedule/update-schedule.do"
// 删除日程
#define kNetPath_Schedule_Delete @"schedule/del-schedule.do"
// 接受日程 参数-日程参与人id（staffId），日程id(scheduleId)
#define kNetPath_Schedule_Receive @"schedule/receive-schedule.do"
// 拒绝日程 参数-日程参与人id（staffId），日程id(scheduleId) 拒绝原因（refuseInfo
#define kNetPath_Schedule_Refuse @"schedule/refuse-schedule.do"
// 退出日程 参数：id(日程 scheduleId)
#define kNetPath_Schedule_Quit @"schedule/quit-schedule.do"


#pragma mark - 重置密码
#define RESET_PASSWORD_ACTION @"common/reset-password.do"

#pragma mark - 提交验证码
#define VERFY_SMS_CODE_ACTION @"common/verfy-sms-code.do"

#pragma mark - 设置新密码
#define SET_NEW_PASSWORD_ACTION @"common/set-new-password.do"



#pragma mark - 知识库
///获取所有部门
#define KNOWLEDGE_GET_ALL_DEPARTMENT @"knowledge/all-department.do"

///获取某部门下/我的知识库  参数：type(1-部门 2-我的知识库 3-群组), id(部门/群组ID), sid(目录ID)
#define KNOWLEDGE_GET_ALL_FILES @"knowledge/get-department-file.do"

///收藏文件  参数：id(文件ID)
#define KNOWLEDGE_ADD_COLLECTION @"knowledge/add-collection.do"
///取消收藏文件  参数：id(文件ID)
#define KNOWLEDGE_CANCEL_COLLECTION @"knowledge/cancel-collection.do"
///删除服务器文件  参数：id(文件ID)
#define KNOWLEDGE_DELETE_SERVICE_FILE @"knowledge/delete.do"



#pragma mark - 搜索相关

///知识库搜索 type:11  searchName搜索内容  pageNo
#define SEARCH_KNOWLEDGE_FILE @"knowledge/get-department-file.do"



#pragma mark - 产品模块
///获取产品分组/列表  参数 （Long parentId（产品模块进入传空）,String pageNo, String pageSize, String name(进行网络搜索)）  返回的type：1 目录 2产品
#define GET_PRODUCT_GROUP_LIST_ACTION @"product/getProductList.do"
///获取产品详情
#define GET_PRODUCT_DETAILS_ACTION @"product/getProductDetail.do"
//产品详情文件
#define GET_PRODCUT_FILE_ACTION @"product/getFile.do"

#pragma mark - 线索公海池
///获取线索公海池
#define GET_CLUE_HIGH_SEA_POOL_ACTION @""
///获取线索公海池分组详情
#define GET_CLUE_HIGH_SEA_POOL_GROUP_DETAILS_ACTION @""

#pragma mark - 客户公海池
///获取客户公海池
#define GET_CUSTOMER_HIGH_SEA_POOL_ACTION @""
///获取客户公海池分组详情
#define GET_CUSTOMER_HIGH_SEA_POOL_GROUP_DETAILS_ACTION @""


#pragma mark - 获取CRM-客户列表

#define GET_CRM_CUSTOMER_LIST_ACTION @"customer/getCustomerList.do"


#pragma mark - 获取CRM-联系人列表

#define GET_CRM_CONTACT_LIST_ACTION @""


#pragma mark - 日程
#define GET_OFFICE_SCHEDULE_GET_LIST @"schedule/get-schedule-list.do" //获取日程列表
#define GET_OFFICE_SCHEDULE_CREATE @"schedule/create_schedule.do" //创建日程
#define GET_OFFICE_SCHEDULE_GET_TYPE @"schedule/get-color-type.do" //获取日程类型
#define GET_OFFICE_SCHEDULE_GET_BECONFIRMED @"schedule/get-beConfirmed.do" //获取待确认日程列表
#define GET_OFFICE_SCHEDULE_DEL @"schedule/del-schedule.do" //删除日程
#define GET_OFFICE_SCHEDULE_GET_RECEIVE @"schedule/receive-schedule.do" //scheduleId日程id,staffId接受日程用户id
#define GET_OFFICE_SCHEDULE_REFUSE @"schedule/refuse-schedule.do" //拒绝日程 scheduleId日程id staffId拒绝人的id refuseInfo拒绝理由
#define GET_OFFICE_SCHEDULE_QUIT @"schedule/quit-schedule.do" //退出日程 staffId退出人的id  scheduleId日程id
#define GET_OFFICE_SCHEDULE_LATER @"schedule/delayScheduleTime.do" //延时 id startDate  endDate(2015-12-26时间格式)
//获某一个月有日程的时间（日历下标小点） uid 用户的id  month 月份xxxx-xx  showTask 是否显示任务 isFinish 是否显示已完成任务
#define GET_OFFICE_SCHEDULE_DAYS @"schedule/get-schedule-days.do"


#pragma mark - 任务模块
#define GET_OFFICE_TASK_TODO @"task/get-todo-list.do" //待办任务列表 参数：pageNo(分页参数)
#define GET_OFFICE_TASK_FINISH @"task/get-finish-task-list.do"  //已完成任务
#define GET_OFFICE_TASK_DETAIL @"task/get-task-detail.do"  //查看任务详情
#define GET_OFFICE_TASK_QUIT @"task/quit-task.do"  //退出任务
#define GET_OFFICE_TASK_CREATE @"task/create-task.do"  //创建任务  参数：taskName(任务名称),priority(级别),description(描述),remind(提醒时间),planFinishDate(计划完成时间),memberIds(参与人)
#define GET_OFFICE_TASK_DELETE @"task/delete-task.do" //删除任务
#define GET_OFFICE_TASK_CHANGE @"task/change-status.do" //改变任务 传入参数:taskId(任务id)， "status"（2：未完成；3：已完成）
#define GET_OFFICE_TASK_ACCEPT @"task/accept-task.do" //接受任务  参数： taskId（任务ID）
#define GET_OFFICE_TASK_REFUSE @"task/refuse-task.do" //拒绝任务 参数： taskId（任务ID） reason (拒绝原因)


#pragma mark - CRM相关接口

#pragma mark - 市场活动
///市场活动列表
#define GET_CAMPAIGN_LIST @"market-activity/getActivityList.do"
///获取市场活动下拉列表内容
#define GET_CAMPAIGN_SELECT_LIST @"market-activity/getSelectList.do"
///市场活动筛选类型
#define GET_CAMPAIGN_FILTER @"market-activity/getFilter.do"
// 创建市场活动
#define kNetPath_Market_Create @"market-activity/initCreateAcitvity.do"
///市场活动详情   参数id
#define GET_CAMPAIGN_DETAILS @"market-activity/getActivityDetail.do"
///详情中间的销售线索   参数id type 0
#define GET_CAMPAIGN_DETAILS_SALELEADS @"common/getSaleLeads.do"
///详情中间的客户   参数id type 0
#define GET_CAMPAIGN_DETAILS_CUSTOMER @"common/getCustomer.do"
///详情中间的日程，任务   参数id type 0
#define GET_CAMPAIGN_DETAILS_TASKSCHEDULE @"common/getTaskSchedule.do"
///详情中间的审批   参数id type 0
#define GET_CAMPAIGN_DETAILS_APPROVAL @"common/getApproval.do"
///详情中间的文档   参数id type 0
#define GET_CAMPAIGN_DETAILS_FILE @"common/getFile.do"
///详情中间的跟进记录   参数id type 0
#define GET_CAMPAIGN_DETAILS_FOLLOWRECORD @"common/getFollowRecord.do"

#pragma mark - 客户
// 获取客户类型
#define kNetPath_Customer_CustomerType @"customer/getCustomerTypes.do"
// 客户初始化
#define kNetPath_Customer_InitCustomer @"customer/initCustomer.do"

#pragma mark - 线索公海池
// 创建销售线索
#define kNetPath_Sale_Create @"saleLeads/initSaleLead.do"

#pragma mark - 联系人
#define kNetPath_Contact_Create @"contacts/initContact.do"

#pragma mark - 销售机会
// 获取销售机会的业务类型
#define kNetPath_SaleChance_Types @"saleChance/getSaleChanceTypes.do"
#define kNetPath_SaleChance_Create @"saleChance/initSaleChance.do"

#pragma mark - IM接口
//链接IM

//待办提醒列表
#define GET_WAIT_REMINDS @"message/searchReminds.do" // 分页参数：pageNo pageSize
//提醒列表中 全部已读
#define GET_ALL_ISREAD @"message/markRemindHadRead.do" //
//提醒列表中 一个已读
#define GET_ONE_ISREAD @"message/singleRemindUpdate.do" //参数 id
//通知列表
#define GET_ALL_NOTICE @"message/searchAllNotice.do"
//公告列表
#define GET_ANNOUNCEMENT_LIST @"message/searchAnnouncement.do"
//公告详情
//#define GET_ANNOUNCEMENT_DETAIL @"message/readAnnouncementDetail.do"
#define GET_ANNOUNCEMENT_DETAIL @"message/getAnnouncementDetail.do"

//部门公告全部已读
#define GET_ANNOUNCEMENT_ALL_ISREAD @"message/markAnnounceHadRead.do"
//单个未读通知
#define GET_ANNOUNCEMENT_ONE_ISREAD @"message/singleNoticeUpdate"
//提到我的 @我
#define GET_AT_TO_ME @"message/searchAtToMe.do"


//IM中用户头像 url前缀
#define GET_IM_ICON_URL [NSString stringWithFormat:@"%@/%@",SKT_SERVER_IP, SKT_P]
#define GET_IM_FILR_URL [NSString stringWithFormat:@"%@/%@",SKT_IM_SERVER_IP, SKT_IM_GET_FILE_ACTION]

//回话列表  userId 当前用户id    pageSize 分页
//#define IM_GET_CONVERSATION_LIST @"getConversationListByApp.do" //老接口
#define IM_GET_CONVERSATION_LIST @"getConversationListByAppBeta.do"


//创建组  userId当前用户的id     ids除当前用户外的其他用户id  content消息内容 resource上传的附件
#define IM_GET_CREATE_GROUP @"createGroup.do"
//创建部门讨论组 groupName部门名称 ids除当前用户外的其他用户id  content消息内容 resource上传的附件
#define IM_GET_CREATE_COMPANY_GROUP @"createGroupByDepart.do"
//删除/退出组、删除组成员  userId当前用户的id     userName当前用户名称    groupId组id
#define IM_GET_DELETE_GROUP @"exitGroup.do"
//修改讨论组名称  userId当前用户的id     name新讨论组名称    groupId组id
#define IM_GET_GROUP_NAME @"updateGroupName.do"
//添加组成员  userId当前用户的id     ids除当前用户外的其他用户id    groupId组id
#define IM_GET_ADD_CONTACTS_GROUP @"joinGroup.do"
//获取会话列表 userId当前用户的id   groupId组id  number消息序号 flag当前消息number pageSize一页数量
//#define IM_GET_GROUP_CONVERSATION_LIST @"getGroupConversation.do"
//#define IM_GET_GROUP_CONVERSATION_LIST @"getGroupConversationNew.do"
#define IM_GET_GROUP_CONVERSATION_LIST @"getGroupConversationBeta.do" //3.0.3接口

//上传文件 语音，图片 userId 当前用户id  companyId 公司id second 声音的秒数    file文件
#define IM_GET_UPLOAD_FILE @"upload.do"
//部门列表
//#define IM_GET_DEPARTMENT_LIST @"getDepartmentList.do"  //companyId 公司id
#define IM_GET_DEPARTMENT_LIST @"getDepartmentListNew.do"  //companyId 公司id
//部门下所对应的人
#define IM_GET_DEPTUSER_LIST @"getDeptUserList.do" //deptId 部门id

#pragma mark - 未读个数 
//type 1提醒 2通知 3工作报告 4审批 5日程 6任务
//消息模块
#define OFFICE_UNREAD_COUNT @"message/getUnReadOaMsg.do"
//办公模块
#define MESSAGE_UNREAD_COUNT @"message/getUnReadMsg.do"

///轮询接口
#define MESSAGE_UNREAD_FOR_CYCLE @"message/getUnReadMsgForCycle.do"

#pragma mark - 首页搜索
#define HOME_SEARCH_ACTION @"universal/searchCrmData.do"

#pragma mark - 关联业务，搜索  公共参数：name搜索关键字 pageNo分页 pageSize分页条数
//销售线索
#define RELATED_SALE_LEAD @"saleLeads/getClues.do"
//客户
#define RELATED_CUSTOMER @"customer/getCustomers.do"
//联系人
#define RELATED_CONTACT @"contacts/getLinkMans.do"
//市场活动
#define RELATED_MARKET @"market-activity/getActivitys.do"
//销售机会
#define RELATED_SALE_CHANCE @"saleChance/getOpportunitys.do"


#pragma mark - 获取喜报
/// 获取喜报列表接口
#define VICTORY_OPPORTUNITY_LIST_ACTION @"saleChance/getVictoryOpportunitys.do"


#pragma mark - 检测版本
///检测版本
#define SKT_CHECK_APP_VERSION @"common/getAppVersion.do"


#import <Foundation/Foundation.h>

@interface AFNHttp : NSObject


/**
 *  发送一个GET请求  异步
 *
 *  @param url     请求路径
 *  @param params  请求参数
 *  @param success 请求成功后的回调
 *  @param failure 请求失败后的回调
 */
+ (void)get:(NSString *)url params:(NSDictionary *)params success:(void(^)(id responseObj))success failure:(void(^)(NSError *error))failure;

/**
 *  发送一个POST请求 异步
 *
 *  @param url     请求路径
 *  @param params  请求参数
 *  @param success 请求成功后的回调
 *  @param failure 请求失败后的回调（
 */
+ (void)post:(NSString *)url params:(NSDictionary *)params success:(void(^)(id responseObj))success failure:(void(^)(NSError *error))failure;


/**
 *  发送一个GET/POST请求 同步
 *
 *  @param url     请求路径
 *  @param params  请求参数
 *  @return  请求返回数据（
 */
// 同步get/post请求
+(id)doSynType:(NSString *)method WithUrl:(NSString *)url params:(NSDictionary *)params;

// 取消所有请求
+(void)cancelAllRequest;

@end


