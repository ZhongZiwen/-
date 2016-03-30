//
//  Net_APIUrl.h
//  shangketong
//
//  Created by sungoin-zbs on 15/7/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#ifndef shangketong_Net_APIUrl_h
#define shangketong_Net_APIUrl_h
#endif

#define Code_CookieData      @"sessionCookies"

/*api接口请求都放这里*/
#pragma mark BaseUrl

#pragma mark - 登录登出
// 登录
#define kNetPath_Login @"j_spring_security_check"
// 注销
#define kNetPath_Logout @"j_spring_security_logout"
// 选择公司 参数：tenantId（用户ID）
#define kNetPath_ChooseCompany @"user/chooseCompany.do"

#pragma mark - 注册
// 获取验证码
#define kNetPath_SendCaptcha @"user/sendCaptcha.do"
// 提交账户和验证码
#define kNetPath_CheckAccountName @"user/validate/checkAccountName.do"
// 提交账户和密码
#define kNetPath_CheckAccountPassword @"user/checkAccountPassword.do"
// 新建公司信息，提交
#define kNetPath_RegisterInit @"user/registerInit.do"
// 修改密码
#define kNetPath_updatePassword @"user/updatePassword.do"

#pragma mark - 找回密码
// 获取验证码
#define kNetPath_ResetPassword @"common/reset-password.do"
// 检测验证码
#define kNetPath_VerificationCode @"common/verfy-sms-code.do"
// 重置密码
#define kNetPath_SetNewPassword @"common/set-new-password.do"


#pragma mark - 评论
// 获取评论列表
#define kNetPath_Common_CommentList @"comment/comment-list.do"
// 添加评论
#define kNetPath_Common_AddComment @"comment/add-comment.do"
// 删除评论
#define kNetPath_Common_DeleteComment @"comment/deleteComment.do"

#pragma mark - 首页

#pragma mark - 消息

#pragma mark - crm
/************Common***********/
// 详情中获取跟进记录
#define kNetPath_Common_FollowRecord @"universal/getFollowRecord.do"
// 详情中获取销售线索列表
#define kNetPath_Common_SaleLeads @"universal/getSaleLeads.do"
// 详情中获取客户列表
#define kNetPath_Common_Customer @"universal/getCustomer.do"
// 详情中获取审批列表
#define kNetPath_Common_Approval @"universal/getApproval.do"
// 详情中获取文档列表
#define kNetPath_Common_File @"universal/getFile.do"
// 收藏文档
#define kNetPath_Common_File_Favorite @"universal/addFavorite.do"
// 取消收藏文档
#define kNetPath_Common_File_CancelFavorite @"universal/cancelFavorite.do"
// 删除文档
#define kNetPath_Common_File_Delete @"universal/delResource.do"
// 详情中产品列表
#define kNetPath_Common_ProductsList @"universal/getProducts.do"

// 删除快速记录（动态）
#define kNetPath_Common_DeleteActivity @"universal/delActivityLog.do"
// 市场活动中修改客户参与状态
#define kNetPath_Common_ChangeCustomerStatus @"universal/getCustomerStates.do"

/************市场活动***********/
// 市场活动初始化
#define kNetPath_Activity_Init @"market-activity/initData.do"
// 市场活动列表
#define kNetPath_Activity_List @"market-activity/getActivityList.do"
// 获取市场活动下拉列表内容
#define kNetPath_Activity_Select_List @"market-activity/getSelectList.do"
// 市场活动筛选类型
#define kNetPath_Activity_Filter @"market-activity/getFilter.do"
// 创建市场活动
#define kNetPath_Activity_Create @"market-activity/initCreateAcitvity.do"
// 获取市场活动详情
#define kNetPath_Activity_Detail @"market-activity/getActivityDetail.do"
// 获取市场活动详情跟进记录
#define kNetPath_Activity_FollowRecord @"market-activity/getFollowRecord.do"
// 编辑或新增市场活动
#define kNetPath_Activity_EditOrSave @"market-activity/editOrSaveActivity.do"
// 修改市场活动状态
#define kNetPath_Activity_ChangeStatus @"market-activity/changeStatus.do"
// 关注或取消关注市场活动
#define kNetPath_Activity_FocusOrCancel @"market-activity/focusOrCancel.do"
// 转移此市场活动给其他人
#define kNetPath_Activity_Transfer @"market-activity/transfer.do"
// 删除该市场活动
#define kNetPath_Activity_Delete @"market-activity/delete.do"
// 修改团队成员权限
#define kNetPath_Activity_UpdateAccess @"market-activity/updateAccess.do"
// 删除负责员工或相关员工
#define kNetPath_Activity_DeleteStaff @"market-activity/delSomeone.do"
// 添加成员（权限为相关成员，不是负责成员）
#define kNetPath_Activity_AddStaffs @"market-activity/addRelativeCrews.do"
// 快速记录
#define kNetPath_Activity_SendRecord @"market-activity/recordFast.do"
// 详情销售线索
#define kNetPath_Activity_SaleLeadsList @"market-activity/getCluesFromActivity.do"
// 详情客户列表
#define kNetPath_Activity_CustomerList @"market-activity/getCustomersFromActivity.do"
// 详情日程任务列表
#define kNetPath_Activity_TaskScheduleList @"market-activity/getTaskSchedule.do"
// 新建任务
#define kNetPath_Activity_CreateSchedule @"market-activity/create_schedule.do"
// 新建日程
#define kNetPath_Activity_CreateTask @"market-activity/createTask.do"
// 详情审批列表
#define kNetPath_Activity_ApprovalList @"market-activity/getApproval.do"
// 详情文档列表
#define kNetPath_Activity_FileList @"market-activity/getFile.do"
// 修改详情中客户的参与状态
#define kNetPath_Activity_UpdateAttendedStatus @"market-activity/updateAttendedStatus.do"


/************公海池***********/
// 获取销售线索公海池分组列表
#define kNetPath_LeadPool_List @"leadsPool/getLeadsPoolList.do"
// 获取销售线索公海池分组中线索详情
#define kNetPath_LeadPool_Detail @"leadsPool/getLeadsPoolDetail.do"
// 领取销售线索
#define kNetPath_LeadPool_Get @"leadsPool/goAndGet.do"

// 获取客户公海池分组列表
#define kNetPath_CustomerPool_List @"customerPool/getCustomerPoolList.do"
// 获取客户公海池分组中客户详情
#define kNetPath_CustomerPool_Detail @"customerPool/getCustomerPoolDetail.do"
// 领取客户
#define kNetPath_CustomerPool_Get @"customerPool/goAndGet.do"


/************销售线索***********/
// 销售线索初始化
#define kNetPath_Lead_Init @"saleLeads/initData.do"
// 获取检索下拉列表的内容
#define kNetPath_Lead_Select_List @"saleLeads/getSelectList.do"
// 获取筛选类型列表
#define kNetPath_Lead_Filter @"saleLeads/getFilter.do"
// 获取销售线索列表
#define kNetPath_Lead_List @"saleLeads/getSaleLeadsList.do"
// 新建销售线索
#define kNetPath_Lead_New @"saleLeads/initSaleLead.do"
// 销售线索详情
#define kNetPath_Lead_Detail @"saleLeads/getSaleLeadsDetail.do"
// 销售线索详情跟进记录
#define kNetPath_Lead_FollowRecord @"saleLeads/getFollowRecord.do"
// 新增或编辑线索
#define kNetPath_Lead_EditOrSave @"saleLeads/editOrSaveSaleLead.do"
// 销售线索名片扫描
#define kNetPath_Lead_Scanning @"saleLeads/scanCard.do"
// 改变销售线索跟进状态
#define kNetPath_Lead_ChangeStatus @"saleLeads/changeStatus.do"
// 转移此销售线索给其他人
#define kNetPath_Lead_Transfer @"saleLeads/transfer.do"
// 删除该销售线索
#define kNetPath_Lead_Delete @"saleLeads/delete.do"
// 快速记录
#define kNetPath_Lead_SendRecord @"saleLeads/recordFast.do"
// 详情日程任务列表
#define kNetPath_Lead_TaskScheduleList @"saleLeads/getTaskSchedule.do"
// 新建任务
#define kNetPath_Lead_CreateSchedule @"saleLeads/create_schedule.do"
// 新建日程
#define kNetPath_Lead_CreateTask @"saleLeads/createTask.do"
// 搜索销售线索
#define kNetPath_Lead_Search @"saleLeads/getClues.do"
// 详情审批列表
#define kNetPath_Lead_ApprovalList @"saleLeads/getApproval.do"
// 初始化转换为我的客户
#define kNetPath_Lead_ChangeToCustomerInit @"saleLeads/changeSaleLeadToCustomerInit.do"
// 转换为我的客户
#define kNetPath_Lead_ChangeToCustomer @"saleLeads/changeSaleLeadToCustomer.do"
// 废弃
#define kNetPath_Lead_Trash @"saleLeads/trash.do"
// 退回线索池理由
#define kNetPath_Lead_BackReason @"saleLeads/backReason.do"
// 退回到线索池
#define kNetPath_Lead_BackToPool @"saleLeads/backToPool.do"


/************客户***********/
// 客户初始化
#define kNetPath_Customer_Init @"customer/initData.do"
// 获取客户列表
#define kNetPath_Customer_List @"customer/getCustomerList.do"
// 获取检索下拉列表的内容
#define kNetPath_Customer_Select_List @"customer/getSelectList.do"
// 获取客户筛选列表
#define kNetPath_Customer_Filter @"customer/getFilter.do"
// 新建客户初始化
#define kNetPath_Customer_New @"customer/initCustomer.do"
// 名片扫描初始化
#define kNetPath_Customer_Scanning @"customer/scanCard.do"
// 新增或编辑客户
#define kNetPath_Customer_EditOrSave @"customer/editOrSaveCustomer.do"
// 关注或取消关注客户
#define kNetPath_Customer_FocusOrCancel @"customer/focusOrCancel.do"
// 客户详情
#define kNetPath_Customer_Detail @"customer/getCustomerDetail.do"
// 客户跟进记录
#define kNetPath_Customer_FollowRecord @"customer/getFollowRecord.do"
// 客户转移
#define kNetPath_Customer_Transfer @"customer/transfer.do"
// 废弃
#define kNetPath_Customer_Trash @"customer/trash.do"
// 快速记录
#define kNetPath_Customer_SendRecord @"customer/recordFast.do"
// 详情日程任务列表
#define kNetPath_Customer_TaskScheduleList @"customer/getTaskSchedule.do"
// 新建任务
#define kNetPath_Customer_CreateSchedule @"customer/create_schedule.do"
// 新建日程
#define kNetPath_Customer_CreateTask @"customer/createTask.do"
// 市场活动中添加客户
#define kNetPath_Customer_AddCustomerFromActivity @"market-activity/addCustomerFromActivity.do"
// 搜索客户
#define kNetPath_Customer_Search @"customer/getCustomers.do"
// 删除客户
#define kNetPath_Customer_Delete @"customer/delete.do"
// 修改团队成员权限
#define kNetPath_Customer_UpdateAccess @"customer/updateAccess.do"
// 删除负责员工或相关员工
#define kNetPath_Customer_DeleteStaff @"customer/delSomeone.do"
// 添加成员（权限为相关成员，不是负责成员）
#define kNetPath_Customer_AddStaffs @"customer/addRelativeCrews.do"
// 详情审批列表
#define kNetPath_Customer_ApprovalList @"customer/getApproval.do"
// 详情文档列表
#define kNetPath_Customer_FileList @"customer/getFile.do"
// 退回线索池理由
#define kNetPath_Customer_BackReason @"customer/backReason.do"
// 退回到线索池
#define kNetPath_Customer_BackToPool @"customer/backToPool.do"
// 新建销售机会
#define kNetPath_Customer_NewOpportunity @"customer/initOpportunity.do"
// 保存新建的销售机会
#define kNetPath_Customer_SaveNewOpportunity @"customer/addOpportunity.do"
// 新建联系人
#define kNetPath_Customer_NewContact @"customer/initLinkMan.do"
// 新建联系人 扫描初始化
#define kNetPath_Customer_ScanningFromCustomer @"customer/scanLinkManFromCustomer.do"
// 保存新建联系人
#define kNetPath_Customer_SaveNewContact @"customer/addLinkMan.do"


/************联系人***********/
// 联系人初始化
#define kNetPath_Contact_Init @"contacts/initData.do"
// 获取联系人列表
#define kNetPath_Contact_List @"contacts/getContactsList.do"
// 获取筛选类型列表
#define kNetPath_Contact_Filter @"contacts/getFilter.do"
// 获取检索下拉列表的内容
#define kNetPath_Contact_Select_List @"contacts/getSelectList.do"
// 新建联系人初始化
#define kNetPath_Contact_New @"contacts/initContact.do"
// 名片扫描初始化
#define kNetPath_Contact_Scanning @"contacts/scanCard.do"
// 名片扫描新建联系人，确认公司名称
#define kNetPath_Contact_ValidateCustomer @"customer/validateCustomer.do"
// 保存或编辑联系人
#define kNetPath_Contact_EditOrSave @"contacts/editOrSaveContact.do"
// 获取联系人详情
#define kNetPath_Contact_Detail @"contacts/getContactDetail.do"
// 联系人跟进记录
#define kNetPath_Contact_FollowRecord @"contacts/getFollowRecord.do"
// 联系人转移
#define kNetPath_Contact_Transfer @"contacts/transfer.do"
// 快速记录
#define kNetPath_Contacts_SendRecord @"contacts/recordFast.do"
// 删除联系人
#define kNetPath_Contact_Delete @"contacts/delete.do"
// 详情日程任务列表
#define kNetPath_Contact_TaskScheduleList @"contacts/getTaskSchedule.do"
// 新建任务
#define kNetPath_Contact_CreateSchedule @"contacts/create_schedule.do"
// 新建日程
#define kNetPath_Contact_CreateTask @"contacts/createTask.do"
// 详情审批列表
#define kNetPath_Contact_ApprovalList @"contacts/getApproval.do"
// 客户中获取联系人列表
#define kNetPath_Contact_ListFromCustomer @"contacts/getLinkMansByCustomer.do"
// 新建销售机会
#define kNetPath_Contact_NewOpportunity @"contacts/initOpportunity.do"
// 保存新建销售机会
#define kNetPath_Contact_SaveNewOpportunity @"contacts/addOpportunity.do"
// 修改团队成员权限
#define kNetPath_Contact_UpdateAccess @"contacts/updateAccess.do"
// 删除负责员工或相关员工
#define kNetPath_Contact_DeleteStaff @"contacts/delSomeone.do"
// 添加成员（权限为相关成员，不是负责成员）
#define kNetPath_Contact_AddStaffs @"contacts/addRelativeCrews.do"


/************销售机会***********/
// 初始化
#define kNetPath_SaleChance_Init @"saleChance/initData.do"
// 获取销售机会阶段列表
#define kNetPath_SaleChance_StageList @"saleChance/getSaleChanceStageList.do"
// 获取某个阶段下的销售机会 id - 阶段id
#define kNetPath_SaleChance_List @"saleChance/getOpportunityList.do"
// 获取检索下拉列表的内容
#define kNetPath_SaleChance_Select_List @"saleChance/getSelectList.do"
// 获取筛选类型类型
#define kNetPath_SaleChance_Filter @"saleChance/getFilter.do"
// 获取销售机会类型
#define kNetPath_SaleChance_Type @"saleChance/getSaleChanceTypes.do"
// 新建销售机会初始化
#define kNetPath_SaleChance_NewInit @"saleChance/initSaleChance.do"
// 新建或编辑保存销售机会
#define kNetPath_SaleChance_EditOrSave @"saleChance/editOrSaveSaleChance.do"
// 关注或取消关注销售机会
#define kNetPath_SaleChance_FocusOrCancel @"saleChance/focusOrCancel.do"
// 销售机会详情
#define kNetPath_SaleChance_Detail @"saleChance/getSaleChanceDetail.do"
// 详情中联系人
#define kNetPath_SaleChance_ContactList @"saleChance/getLinkMans.do"
// 详情中新建联系人初始化
#define kNetPath_SaleChance_ContactNewInit @"saleChance/initLinkMan.do"
// 详情中扫描名片联系人初始化
#define kNetPath_SaleChance_ContactScanInit @"saleChance/scanLinkManFromOpportunity.do"
// 详情中保存新建联系人
#define kNetPath_SaleChance_ContactAdd @"saleChance/addLinkMan.do"
// 详情中日程任务
#define kNetPath_SaleChance_TaskScheduleList @"saleChance/getTaskSchedule.do"
// 详情中审批
#define kNetPath_SaleChance_ApprovalList @"saleChance/getApproval.do"
// 详情中产品
#define kNetPath_SaleChance_ProductsList @"saleChance/getProducts.do"
// 详情中添加产品
#define kNetPath_SaleChance_AddProduct @"saleChance/addProducts.do"
// 详情中保存添加的产品
#define kNetPath_SaleChance_SaveProduct @"saleChance/updateProduct.do"
// 详情中移除产品
#define kNetPath_SaleChance_RemoveProduct @"saleChance/removeProduct.do"
// 详情中文档
#define kNetPath_SaleChance_FileList @"saleChance/getFile.do"
// 详情中新建任务
#define kNetPath_SaleChance_CreateTask @"saleChance/createTask.do"
// 详情中新建日程
#define kNetPath_SaleChance_CreateSchedule @"saleChance/create_schedule.do"
// 快速记录
#define kNetPath_SaleChance_SendRecord @"saleChance/recordFast.do"
// 跟进记录
#define kNetPath_SaleChance_FollowRecord @"saleChance/getFollowRecord.do"
// 转移给他人
#define kNetPath_SaleChance_Transfer @"saleChance/transfer.do"
// 删除销售机会
#define kNetPath_SaleChance_Delete @"saleChance/delete.do"
// 修改销售阶段
#define kNetPath_SaleChance_ChangeStage @"saleChance/updateSaleStage.do"
// 客户中获取销售机会列表
#define kNetPath_SaleChance_ListFromCustomer @"saleChance/getOpportunitysFromCustomer.do"
// 联系人中获取销售机会列表
#define kNetPath_SaleChance_ListFromContact @"saleChance/getOpportunitysFromLinkMan.do"
// 获取已有联系人列表
#define kNetPath_SaleChance_ContactListFromOpportunity @"saleChance/getLinkMansFromOpportunity.do"
// 添加已有联系人
#define kNetPath_SaleChance_AddContact @"saleChance/addExistLinkMans.do"
// 设置主联系人
#define kNetPath_SaleChance_AssignMainContact @"saleChance/assignTouchLinkMan.do"
// 修改团队成员权限
#define kNetPath_SaleChance_UpdateAccess @"saleChance/updateAccess.do"
// 删除负责员工或相关员工
#define kNetPath_SaleChance_DeleteStaff @"saleChance/delSomeone.do"
// 添加成员（权限为相关成员，不是负责成员）
#define kNetPath_SaleChance_AddStaffs @"saleChance/addRelativeCrews.do"
// 输单理由
#define kNetPath_SaleChance_LoseReasons @"universal/getLoseReasons.do"


/************活动记录***********/
// 获取活动记录列表
#define kNetPath_ActivityRecord_Types @"activityRecord/getActivityRecordType.do"
// 获取某一天某一活动记录类型的活动记录列表 date:yyyy-MM-dd  id:活动记录类型id
#define kNetPath_ActivityRecord_List @"activityRecord/getActivityRecordList.do"
// 获取活动记录类型
#define kNetPath_ActivityRecord_Type @"activityRecord/getRecords.do"



/************产品***********/
// 获取产品列表
#define kNetPath_Product_List @"product/getProductList.do"
// 产品详情
#define kNetPath_Product_Detail @"product/getProductDetail.do"
// 产品详情中文件列表
#define kNetPath_Product_FileList @"product/getFile.do"



#pragma mark - 办公
/************动态***********/
// 删除动态
#define kNetPath_Dynamic_Delete @"dynamic/deleteDynamic.do"
// 赞
#define kNetPath_Dynamic_Like @"dynamic/feed-up-add.do"
// 收藏
#define kNetPath_Dynamic_AddFavorite @"dynamic/addFavorite.do"
// 取消收藏
#define kNetPath_Dynamic_DeleteFavorite @"dynamic/deleteFavorite.do"



/************通讯录***********/
// 通讯录列表
#define kNetPath_Address_List @"address-book/contact-list.do"
// 通讯录部门列表
#define kNetPath_Address_Department_List @"address-book/child-departments-list.do"
// 通讯录群组列表
#define kNetPath_Address_Group_List @"address-book/group-list.do"
// 部门员工 参数 departmentId
#define kNetPath_Address_DepartmentChild_StaffsList @"address-book/child-staffs-list.do"
// 群组员工 参数 groupId
#define kNetPath_Address_GroupChild_StaffList @"address-book/group-staff-list.do"
// 关注  参数 contactId
#define kNetPath_Address_AddFollow @"address-book/add_follow.do"
// 取消关注  参数 contactId
#define kNetPath_Address_CancelFollow @"address-book/cancel_follow.do"
// 动态列表
#define kNetPath_Address_DynamicList @"dynamic/trends-list.do"


/***********工作报告***********/
// 我提交的报告
#define kNetPath_Report_Mine @"work-report/my-report-list.do"
// 提交给我的报告
#define kNetPath_Report_ToMe @"work-report/report-to-me-list.do"
// 全部报告
#define kNetPath_Report_All @"work-report/report-all-list.do"
// 报告详情
#define kNetPath_Report_Details @"work-report/report-detail.do"
// 获取工作报告筛选条件
#define kNetPath_Report_Filter @"work-report/get-filter.do"
// 新建报告
#define kNetPath_Report_Create @"work-report/open-create-report.do"
// 工作报告汇总
#define kNetPath_Report_WorkResult @"work-report/work-result.do"

/************审批**************/
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



/***********日程************/
#define kNetPath_Schedule_Detail @"schedule/get-scheduleInfo.do"
// 获取日程类型
#define kNetPath_Schedule_Type @"schedule/get-color-type.do"
// 删除日程
#define kNetPath_Schedule_Delete @"schedule/del-schedule.do"



/***********任务************/
// 创建任务
#define kNetPath_Task_Create @"task/create-task.do"
// 任务详情
#define kNetPath_Task_Detail @"task/get-task-detail.do"
// 删除任务
#define kNetPath_Task_Delete @"task/delete-task.do"


#pragma mark - 我



