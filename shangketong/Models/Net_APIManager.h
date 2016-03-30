//
//  Net_APIManager.h
//  shangketong
//
//  Created by sungoin-zbs on 15/7/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNOManagerPost.h"
#import "Net_APIUrl.h"

@class Record;

@interface Net_APIManager : NSObject

+ (instancetype)sharedManager;

#pragma 登录
// Login
- (void)request_Login_WithParams:(id)params andBlock:(void(^)(id data, NSError *error))block;
// Logout
- (void)request_Logout_WithParams:(id)params andBlock:(void(^)(id data, NSError *error))block;
// 选择公司
- (void)request_ChooseCompany_WithParams:(id)params andBlock:(void(^)(id data, NSError *error))block;

#pragma mark - 注册
// 获取验证码
- (void)request_SendCaptcha_WithParams:(id)params block:(void(^)(id data, NSError *error))block;
// 提交账户和验证码 检测用户名
- (void)request_CheckAccountName_WithParams:(id)params block:(void(^)(id data, NSError *error))block;
// 提交账户和密码kNetPath_CheckAccountPassword
- (void)request_CheckAccountPassword_WithParams:(id)params block:(void(^)(id data, NSError *error))block;

// 修改密码
- (void)request_UpdatePassword_WithParams:(id)params block:(void(^)(id data, NSError *error))block;

#pragma mark - 找回密码
// 获取验证码
- (void)request_FindPassword_ResetPassword_WithParams:(id)params block:(void(^)(id data, NSError *error))block;
// 检测验证码
- (void)request_FindPassword_VerificationCode_WithParams:(id)params block:(void(^)(id data, NSError *error))block;
// 重置密码
- (void)request_FindPassword_SetNewPassword_WithParams:(id)params block:(void(^)(id data, NSError *error))block;



#pragma mark - Common
// 模块初始化
- (void)request_Common_Init_WithPath:(NSString*)path block:(void(^)(id data, NSError *error))block;
// 详情中获取跟进记录
- (void)request_Common_FollowRecord_List_WithPath:(NSString*)path Params:(id)params block:(void(^)(id data, NSError *error))block;
// 详情销售线索列表
- (void)request_Common_SaleLeadsList_WithParams:(id)params path:(NSString*)path block:(void(^)(id data, NSError *error))block;


#pragma mark - CRM筛选
- (void)request_CRM_Common_Filter_WithPath:(NSString *)aPath block:(void(^)(id data, NSError *error))block;

#pragma mark - CRM索引
- (void)request_CRM_Common_Index_WithPath:(NSString *)aPath block:(void(^)(id data, NSError *error))block;


#pragma mark - CRM详情
// 获取详细资料
- (void)request_Common_CRMDetail_WithPath:(NSString*)path params:(id)params block:(void(^)(id data, NSError *error))block;
// 获取跟进记录
- (void)request_Common_CRMFollowRecord_WithPath:(NSString*)path params:(id)params block:(void(^)(id data, NSError *error))block;
// 快速记录
- (void)request_Common_SendRecord_WithPath:(NSString*)path obj:(Record*)record block:(void(^)(id data, NSError *error))block;
// 关注 & 取消关注
- (void)request_Common_FocusOrCancel_WithPath:(NSString*)path params:(id)params block:(void(^)(id data, NSError *error))block;
// 转移
- (void)request_Common_Transfer_WithPath:(NSString*)path params:(id)params block:(void(^)(id data, NSError *error))block;
// 废弃
- (void)request_Common_Trash_WithPath:(NSString*)path params:(id)params block:(void(^)(id data, NSError *error))block;
// 删除
- (void)request_Common_Delete_WithPath:(NSString*)path params:(id)params block:(void(^)(id data, NSError *error))block;
// 


#pragma mark - 详情-团队成员
// 修改团队成员权限
- (void)request_Common_UpdateAccess_WithParams:(id)params path:(NSString*)path block:(void(^)(id data, NSError *error))block;
// 删除负责员工或相关员工
- (void)request_Common_DeleteStaff_WithParams:(id)params path:(NSString*)path block:(void(^)(id data, NSError *error))block;
// 添加成员（权限为相关成员，不是负责成员）
- (void)request_Common_AddStaffs_WithParams:(id)params path:(NSString*)path block:(void(^)(id data, NSError *error))block;

#pragma mark - 详情—销售机会
// 详情中获取销售机会列表
- (void)request_Common_OpportunityList_WithParams:(id)params path:(NSString*)path block:(void(^)(id data, NSError *error))block;
// 详情中新建销售机会初始化
- (void)request_Common_OpportunityInit_WithParams:(id)params path:(NSString*)path block:(void(^)(id data, NSError *error))block;
// 详情中保存销售机会
- (void)request_Common_OpportunitySave_WithParams:(id)params path:(NSString*)path block:(void(^)(id data, NSError *error))block;

#pragma mark - 详情-联系人
// 详情中获取联系人列表
- (void)request_Common_ContactList_WithParams:(id)params path:(NSString*)path block:(void(^)(id data, NSError *error))block;
// 详情中新建联系人初始化
- (void)request_Common_ContactInit_WithParams:(id)params path:(NSString*)path block:(void(^)(id data, NSError *error))block;
// 详情中保存联系人
- (void)request_Common_ContactSave_WithParams:(id)params path:(NSString*)path block:(void(^)(id data, NSError *error))block;

#pragma mark - 详情-客户
// 详情中获取客户列表
- (void)request_Common_Customer_List_WithParams:(id)params path:(NSString*)path block:(void(^)(id data, NSError *error))block;

#pragma mark - 详情-日程任务
// 详情中获取日程任务列表
- (void)request_Common_TaskSchedule_List_WithPath:(NSString*)path block:(void(^)(id data, NSError *error))block;
// 新建日程任务
- (void)request_Common_CreateTaskSchedule_WithParams:(id)params path:(NSString*)path block:(void(^)(id data, NSError *error))block;

#pragma mark - 详情-审批
// 详情中获取审批列表
- (void)request_Common_Approval_List_WithPath:(NSString*)path params:(id)params block:(void(^)(id data, NSError *error))block;

#pragma mark - 详情-产品
// 详情中获取产品列表
- (void)request_Common_ProductList_WithPath:(NSString*)path params:(id)params block:(void(^)(id data, NSError *error))block;

#pragma mark - 详情-文档
// 详情中获取文档列表
- (void)request_Common_File_List_WithPath:(NSString*)path params:(id)params block:(void(^)(id data, NSError *error))block;
- (void)request_Common_File_WithPath:(NSString*)path params:(id)params block:(void(^)(id data, NSError *error))block;

// 修改状态（活动记录状态、销售线索跟进状态）
- (void)request_Common_ChangeState_WithParams:(id)params path:(NSString*)path block:(void(^)(id data, NSError *error))block;
// 获取退回线索池或客户到公海池的理由
- (void)request_Common_BackReason_WithPath:(NSString*)path block:(void(^)(id data, NSError *error))block;
// 退回销售线索或客户到公海池
- (void)request_Common_BackToPool_WithPath:(NSString*)path params:(id)params block:(void(^)(id data, NSError *error))block;
// 名片扫描
- (void)request_Common_ScanningCard_WithPath:(NSString*)path image:(UIImage*)image params:(id)params block:(void(^)(id data, NSError *error))block;
// 编辑资料，保存
- (void)request_Common_EditOrSave_WithPath:(NSString*)path params:(id)params block:(void(^)(id data, NSError *error))block;


// 搜索，获取市场活动、销售线索、客户、联系人、销售机会列表
- (void)request_Common_SearchList_WithParams:(id)params path:(NSString*)path block:(void(^)(id data, NSError *error))block;

// 删除动态
- (void)request_Common_DeleteActivity_WithParams:(id)params block:(void(^)(id data, NSError *error))block;

// 获取评论列表
- (void)request_Common_CommentList_WithParams:(id)params block:(void(^)(id data, NSError *error))block;
// 添加评论
- (void)request_Common_AddComment_WithParams:(id)params block:(void(^)(id data, NSError *error))block;
// 删除评论
- (void)request_Common_DeleteComment_WithParams:(id)params block:(void(^)(id data, NSError *error))block;


// 市场活动中修改客户参与状态
- (void)request_Common_ChangeCustomerStatus_WithBlock:(void(^)(id data, NSError *error))block;



#pragma mark - 市场活动
// 市场活动初始化
- (void)request_Activity_Init_WithBlock:(void(^)(id data, NSError *error))block;
// 获取市场活动列表
- (void)request_Activity_List_WithParams:(id)params andBlock:(void(^)(id data, NSError *error))block;
// 获取市场活动下拉列表内容
- (void)request_Activity_Menu_List_WithParams:(id)params andBlock:(void(^)(id data, NSError *error))block;
// 市场活动筛选类型
- (void)request_Activity_Filter_WithBlock:(void(^)(id data, NSError *error))block;
// 创建市场活动
- (void)request_Activity_Create_WithBlock:(void(^)(id data, NSError *error))block;
// 获取市场活动详情
- (void)request_Activity_Detail_WithParams:(id)params andBlock:(void(^)(id data, NSError *error))block;
// 编辑或新增市场活动
- (void)request_Activity_EditOrSave_WithParams:(id)params andBlock:(void(^)(id data, NSError *error))block;
// 关注或取消关注市场活动
- (void)request_Activity_FocusOrCancel_WithParams:(id)params andBlock:(void(^)(id data, NSError *error))block;
// 转移此市场活动给其他人
- (void)request_Activity_Transfer_WithParams:(id)params andBlock:(void(^)(id data, NSError *error))block;
// 删除该市场活动
- (void)request_Activity_Delete_WithParams:(id)params andBlock:(void(^)(id data, NSError *error))block;
// 修改详情中客户的参与状态
- (void)request_Activity_UpdateAttendedStatus_WithParams:(id)params block:(void(^)(id data, NSError *error))block;




#pragma mark - 公海池
// 获取公海池分组列表
- (void)request_Pool_GroupList_WithType:(NSInteger)type block:(void(^)(id data, NSError *error))block;
// 获取公海池分组中详情列表
- (void)request_Pool_DetailList_WithType:(NSInteger)type params:(id)params block:(void(^)(id data, NSError *error))block;
// 领取销售线索或客户
- (void)request_Pool_Get_WithType:(NSInteger)type params:(id)params block:(void(^)(id data, NSError *error))block;

#pragma mark - 销售线索
// 销售线索初始化
- (void)request_Lead_Init_WithBlock:(void(^)(id data, NSError *error))block;
// 获取销售线索列表
- (void)request_Lead_List_WithParams:(id)params andBlock:(void(^)(id data, NSError *error))block;
// 销售线索初始化
- (void)request_Lead_New_WithParams:(id)params andBlock:(void(^)(id data, NSError *error))block;
// 获取销售线索下拉列表内容
- (void)request_Lead_Menu_List_WithParams:(id)params andBlock:(void(^)(id data, NSError *error))block;
// 获取销售线索筛选数据
- (void)request_Lead_Filter_WithBlock:(void(^)(id data, NSError *error))block;
// 销售线索详情
- (void)request_Lead_Detail_WithParams:(id)params block:(void(^)(id data, NSError *error))block;
// 新增或编辑线索
- (void)request_Lead_EditOrSave_WithParams:(id)params block:(void(^)(id data, NSError *error))block;
// 转移此销售线索给其他人
- (void)request_Lead_Transfer_WithParams:(id)params block:(void(^)(id data, NSError *error))block;
// 删除该销售线索
- (void)request_Lead_Delete_WithParams:(id)params block:(void(^)(id data, NSError *error))block;
// 搜索销售线索
- (void)request_Lead_Search_WithParams:(id)params block:(void(^)(id data, NSError *error))block;
// 初始化转换为我的客户
- (void)request_Lead_ChangeToCustomerInit_WithParams:(id)params block:(void(^)(id data, NSError *error))block;
// 转换为我的客户
- (void)request_Lead_ChangeToCustomer_WithParams:(id)params block:(void(^)(id data, NSError *error))block;
// 废弃销售线索
- (void)request_Lead_Trash_WithParams:(id)params block:(void(^)(id data, NSError *error))block;



#pragma mark - 客户
// 初始化
- (void)request_Customer_Init_WithBlock:(void(^)(id data, NSError *error))block;
// 客户列表
- (void)request_Customer_List_WithParams:(id)params andBlock:(void(^)(id data, NSError *error))block;
// 新建客户初始化
- (void)request_Customer_New_WithParams:(id)params andBlock:(void(^)(id data, NSError *error))block;
// 客户下拉列表
- (void)request_Customer_Menu_List_WithParams:(id)params andBlock:(void(^)(id data, NSError *error))block;
// 客户筛选数据
- (void)request_Customer_Filter_WithBlock:(void(^)(id data, NSError *error))block;
// 新增或编辑客户
- (void)request_Customer_EditOrSave_WithParams:(id)params block:(void(^)(id data, NSError *error))block;
// 获取客户类型
//- (void)request_Customer_Type_WithParams:(id)params andBlock:(void(^)(id data, NSError *error))block;
// 关注或取消关注
- (void)request_Customer_FocusOrCancelWithParams:(id)params andBlock:(void(^)(id data, NSError *error))block;
// 客户详情
- (void)request_Customer_Detail_WithParams:(id)params block:(void(^)(id data, NSError *error))block;
// 客户转移
- (void)request_Customer_Transfer_WithParams:(id)params block:(void(^)(id data, NSError *error))block;
// 在市场活动中添加客户
- (void)request_Customer_AddCustomerFromActivity_WithParams:(id)params block:(void(^)(id data, NSError *error))block;
// 搜索客户
- (void)request_Customer_Search_WithParams:(id)params block:(void(^)(id data, NSError *error))block;
// 删除客户
- (void)request_Customer_Delete_WithParams:(id)params block:(void(^)(id data, NSError *error))block;
// 新建销售机会
- (void)request_Customer_NewOpportunity_WithParams:(id)params block:(void(^)(id data, NSError *error))block;
// 保存新建销售机会
- (void)request_Customer_SaveNewOpportunity_WithParams:(id)params block:(void(^)(id data, NSError *error))block;



#pragma mark - 联系人
// 初始化
- (void)request_Contact_Init_WithBlock:(void(^)(id data, NSError *error))block;
// 联系人列表
- (void)request_Contact_List_WithParams:(id)params andBlock:(void(^)(id data, NSError *error))block;
// 联系人导航栏列表
- (void)request_Contact_Menu_List_WithParams:(id)params andBlock:(void(^)(id data, NSError *error))block;
// 联系人筛选数据
- (void)request_Contact_Filter_WithBlock:(void(^)(id data, NSError *error))block;
- (void)request_Contact_Filter_WithType:(NSInteger)type andBlock:(void(^)(id data, NSError *error))block;
// 新建联系人初始化
- (void)request_Contact_NewInit_WithPath:(NSString*)path params:(id)params block:(void(^)(id data, NSError *error))block;
// 名片扫描新建联系人，确认客户
- (void)request_Contact_ValidateCustomer_WithParams:(id)params block:(void(^)(id data, NSError *error))block;
// 保存联系人
- (void)request_Contact_EditOrSave_WithPath:(NSString*)path params:(id)params block:(void(^)(id data, NSError *error))block;
// 联系人详情
- (void)request_Contact_Detail_WithParams:(id)params block:(void(^)(id data, NSError *error))block;
// 联系人转移
- (void)request_Contact_Transfer_WithParams:(id)params block:(void(^)(id data, NSError *error))block;
// 删除联系人
- (void)request_Contact_Delete_WithParams:(id)params block:(void(^)(id data, NSError *error))block;
// 客户中获取联系人
- (void)request_Contact_ListFromCustomer_WithParams:(id)params block:(void(^)(id data, NSError *error))block;


#pragma mark - 销售机会
// 获取销售机会阶段列表
- (void)request_SaleChance_StageList_WithParams:(id)params andBlock:(void(^)(id data, NSError *error))block;
// 获取某个阶段下的销售机会
- (void)request_SaleChance_List_WithParams:(id)params andBlock:(void(^)(id data, NSError *error))block;
// 获取检索下拉列表的内容
- (void)request_SaleChance_IndexList_WithParams:(id)params block:(void(^)(id data, NSError *error))block;
// 获取筛选类型类型
- (void)request_SaleChance_Filter_WithBlock:(void(^)(id data, NSError *error))block;
// 获取销售机会类型
- (void)request_SaleChance_Type_WithParams:(id)params andBlock:(void(^)(id data, NSError *error))block;
// 新建销售机会初始化
- (void)request_SaleChance_NewInit_WithParams:(id)params block:(void(^)(id data, NSError *error))block;
// 保存或新建销售机会
- (void)request_SaleChance_EditOrSave_WithParams:(id)params block:(void(^)(id data, NSError *error))block;
// 关注或取消关注销售机会
- (void)request_SaleChance_FocusOrCancel_WithParams:(id)params block:(void(^)(id data, NSError *error))block;
// 销售机会详情
- (void)request_SaleChance_Detail_WithParams:(id)params block:(void(^)(id data, NSError *error))block;
// 销售机会转移给他人
- (void)request_SaleChance_Transfer_WithParams:(id)params block:(void(^)(id data, NSError *error))block;
// 删除销售机会
- (void)request_SaleChance_Delete_WithParams:(id)params block:(void(^)(id data, NSError *error))block;
// 修改销售阶段
- (void)request_SaleChance_ChangeStage_WithParams:(id)params block:(void(^)(id data, NSError *error))block;
// 客户中获取销售机会列表
- (void)request_SaleChance_ListFromCustomer_WithParams:(id)params block:(void(^)(id data, NSError *error))block;
// 获取已有联系人列表
- (void)request_SaleChance_ContactListFromOpportunity_WithParams:(id)params block:(void(^)(id data, NSError *error))block;
// 添加已有联系人
- (void)request_SaleChance_AddContact_WithParams:(id)params block:(void(^)(id data, NSError *error))block;
// 设置主联系人
- (void)request_SaleChance_AssignMainContact_WithParams:(id)params block:(void(^)(id data, NSError *error))block;
// 输单理由
- (void)request_SaleChance_LostReasons_WithBlock:(void(^)(id data, NSError *error))block;



#pragma mark - 活动记录
// 获取活动记录类型数据
- (void)request_ActivityRecord_Types_WithParams:(id)params block:(void(^)(id data, NSError *error))block;
// 获取活动记录列表数据
- (void)request_ActivityRecord_List_WithParams:(id)params block:(void(^)(id data, NSError *error))block;
// 获取活动记录类型
- (void)request_ActivityRecord_Type_WithBlock:(void(^)(id data, NSError *error))block;



#pragma mark - 产品
// 获取产品列表数据
- (void)request_Product_List_WithParams:(id)params block:(void(^)(id data, NSError *error))block;
// 产品详情
- (void)request_Product_Detail_WithParams:(id)params block:(void(^)(id data, NSError *error))block;



#pragma mark - 动态(工作圈)
// 删除动态
- (void)request_Dynamic_Delete_WithParams:(id)params block:(void(^)(id data, NSError *error))block;
// 赞
- (void)request_Dynamic_Like_WithParams:(id)params block:(void(^)(id data, NSError *error))block;
// 收藏和取消收藏
- (void)request_Dynamic_AddOrDeleteFavorite_WithParams:(id)params isFavorite:(BOOL)isFavorite block:(void(^)(id data, NSError *error))block;



#pragma mark - 通讯录
// 获取通讯录列表
- (void)request_Address_List_WithParams:(id)params andBlock:(void(^)(id data, NSError *error))block;
// 获取部门或群组列表
- (void)request_DepartmentOrGroup_List_WithParams:(id)params listType:(NSInteger)type andBlock:(void(^)(id data, NSError *error))block;
// 获取部门员工或群组员工
- (void)request_Address_Member_List_WithParams:(id)params memberType:(NSInteger)type andBlock:(void(^)(id data, NSError *error))block;
// 获取通讯录中部门或群组动态列表
- (void)request_Address_DynamicList_WithParams:(id)params block:(void(^)(id data, NSError *error))block;


#pragma mark - 工作报告
// 获取工作报告列表（我提交的报告、提交给我的报告、全部报告）
- (void)request_Report_List_WithParams:(id)params type:(NSInteger)type andBlock:(void(^)(id data, NSError *error))block;
// 获取工作报告筛选条件
- (void)request_Report_Filter_WithType:(NSInteger)type andBlock:(void(^)(id data, NSError *error))block;
// 新建工作报告
- (void)request_Report_Create_WithParams:(id)params andBlock:(void(^)(id data, NSError *error))block;
// 获取工作自动汇总数据
- (void)request_Report_WorkResult_WithParams:(id)params andBlock:(void(^)(id data, NSError *error))block;


#pragma mark - 审批
// 获取审批列表（我提交的审批、提交给我的审批、全部审批）
- (void)request_Approve_List_WithParams:(id)params andTypeIndex:(NSInteger)typeIndex andBlock:(void(^)(id data, NSError *error))block;
// 获取审批类型列表
- (void)request_Approve_Type_WithParams:(id)params andBlock:(void(^)(id data, NSError *error))block;
// 获取审批流程列表
- (void)request_Approve_Flow_WithParams:(id)params andBlock:(void(^)(id data, NSError *error))block;
// 新建审批申请
- (void)request_Approve_New_WithParams:(id)params andBlock:(void(^)(id data, NSError *error))block;
// 审批详情
- (void)request_Approve_Detail_WithParams:(id)params andBlock:(void(^)(id data, NSError *error))block;
// 提交审批申请
- (void)request_Approve_Submit_WithParams:(id)params andBlock:(void(^)(id data, NSError *error))block;
// 撤回审批
- (void)request_Approve_Reback_WithParams:(id)params andBlock:(void(^)(id data, NSError *error))block;
// 删除审批
- (void)request_Approve_Delete_WithParams:(id)params andBlock:(void(^)(id data, NSError *error))block;
// 同意审批
- (void)request_Approve_Agree_WithParams:(id)params andBlock:(void(^)(id data, NSError *error))block;
// 拒绝审批
- (void)request_Approve_Refuse_WithParams:(id)params andBlock:(void(^)(id data, NSError *error))block;


#pragma mark - 日程
// 日程详情
- (void)request_Schedule_Detail_WithParams:(id)params block:(void(^)(id data, NSError *error))block;
// 获取日程类型
- (void)request_Schedule_Type_WithBlock:(void(^)(id data, NSError *error))block;
// 删除日程
- (void)request_Schedule_Delete_WithParams:(id)params block:(void(^)(id data, NSError *error))block;


#pragma mark - 任务
// 任务详情
- (void)request_Task_Detail_WithParams:(id)params block:(void(^)(id data, NSError *error))block;
// 删除任务
- (void)request_Task_Delete_WithParams:(id)params block:(void(^)(id data, NSError *error))block;

#pragma mark - 我


@end
