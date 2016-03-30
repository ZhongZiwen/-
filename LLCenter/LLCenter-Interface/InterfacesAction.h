//
//  InterfacesAction.h
//  lianluozhongxin
//   接口
//  Created by sungoin-zjp on 15-10-12.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <Foundation/Foundation.h>



///联络中心请求环境
#define LLC_SERVER_IP @"http://mobile.sungoin.cn/platform/"
//#define LLC_SERVER_IP @"http://192.168.1.117:8888/platform/"
//#define LLC_SERVER_IP  @"http://192.168.4.172:8080/platform/"
///--------旧接口--------///

///登陆接口
#define LLC_LOGIN_ACTION @"http/common/login.do"

///获取账号信息
#define LLC_GET_ACCOUNT_INFO_ACTION @"http/query/accountInfo.do"


//---CRM----//
///获取客户列表
#define LLC_GET_CUSTOMER_LIST_ACTION @"http/crm/queryCustomerList.do"
///获取客户标签
#define LLC_GET_CUSTOMER_STATE_FLAG_ACTION @"http/crm/queryCustomerStateFlag.do"
///客户所属用户
#define LLC_GET_CUSTOMER_BELONG_USER_LIST_ACTION @"http/crm/queryUserList.do"
///客户详情及字典信息
#define LLC_GET_CUSTOMER_DETAILS_DICTIONARY_ACTION @"http/crm/initAddCustomerPage.do"
///新建客户
#define LLC_SAVE_CUSTOMER_INFO_ACTION @"http/crm/saveCustomerInfo.do"
///新建联系人
#define LLC_SAVE_LINKMAN_INFO_ACTION @"http/crm/saveLinkmanInfo.do"
///获取客户、联系人详情
#define LLC_GET_CUSTOMER_LINKMAN_INFO_ACTION @"http/crm/queryCustomerLinkmanDetail.do"
///获取客户通讯及业务日志
#define LLC_GET_CUSTOMER_RECORD_LIST_INFO_ACTION @"http/crm/queryCustomerRecordLog.do"
///编辑客户
#define LLC_EDIT_CUSTOMER_INFO_ACTION @"http/crm/updateCustomerInfo.do"


//---CRM----//

//---话单---//
///外呼
#define LLC_OUT_CALL_ACTION @"http/common/outCallBack.do"
///获取音频URL
#define LLC_GET_VOICE_URL_ACTION @"http/common/getVoiceUrl.do"
///获取语音信箱URL
#define LLC_GET_LISTEN_BOX_URL_ACTION @"http/common/getlistenBoxdUrl.do"

///获取已接来电
#define LLC_GET_RECEIVED_CALL_ACTION @"http/query/receivedCall.do"
///获取未接来电
#define LLC_GET_NO_ANSWER_DETAIL_ACTION @"http/query/noAnswerDetail.do"
///获取外呼记录
#define LLC_GET_VOIP_CALL_RECORD_ACTION @"http/query/voipCallRecord.do"
///获取语音信箱
#define LLC_GET_VOICE_BOX_ACTION @"http/query/voiceBox.do"


///获取已接来电筛选条件
#define LLC_GET_RECEIVED_CALL_FILTER_ACTION @"http/query/allSit.do"
///获取未接来电筛选条件
#define LLC_GET_NO_ANSWER_DETAIL_FILTER_ACTION @"http/query/noAnswerSit.do"
///获取外呼记录筛选条件
#define LLC_GET_VOIP_CALL_RECORD_FILTER_ACTION @"http/query/voipAgentAgent.do"
///获取语音信箱筛选条件
#define LLC_GET_VOICE_BOX_FILTER_ACTION @"http/query/noVoiceBox.do"

//---话单---//

//---坐席---//
///获取坐席列表
#define LLC_GET_SIT_LIST_ACTION @"http/sitSet/sitList.do"
///获取坐席详情
#define LLC_GET_SIT_DETAIL_ACTION @"http/sitSet/sitDetail.do"
///编辑坐席
#define LLC_EDIT_SIT_DETAIL_ACTION @"http/sitSet/editSit.do"
///删除坐席
#define LLC_DELETE_SIT_DETAIL_ACTION @"http/sitSet/delSit.do"
///新增坐席
#define LLC_ADD_SIT_DETAIL_ACTION @"http/sitSet/addSit.do"
///获取所有部门列表
#define LLC_GET_DEPT_LIST_ACTION @"http/sitSet/deptList.do"
///校验绑定手机号码
#define LLC_CHECK_BIND_PHONE_ACTION @"http/common/checkBindPhone.do"
///校验工号
#define LLC_CHECK_USER_CODE_ACTION @"http/common/checkUserCode.do"
///获取工号和是否有下级部门 用于判断新增坐席是否需要选部门
#define LLC_GET_GH_AND_ISDEPT_ACTION @"http/sitSet/getGhAndIsDept.do"

//---坐席---//

//---统计报表---//
///获取统计报表-时间
#define LLC_GET_REPORT_TIME_ACTION @"http/query/timeReport.do"
///获取统计报表-坐席
#define LLC_GET_REPORT_SIT_ACTION @"http/query/sitReport.do"
///获取统计报表-时段
#define LLC_GET_REPORT_TIMEINTERVAL_ACTION @"http/query/timeIntervalReport.do"
///获取统计报表-区域
#define LLC_GET_REPORT_AREA_ACTION @"http/query/areaReport.do"
//---统计报表---//



//---黑白名单---//
///获取黑白名单列表
#define LLC_GET_BLACK_AND_WHITE_LIST_ACTION @"http/crm/findBlackAndWhiteList.do"
///删除黑白名单
#define LLC_DELETE_BLACK_AND_WHITE_LIST_ACTION @"http/crm/deleteBlackAndWhiteList.do"
///新增黑白名单
#define LLC_ADD_BLACK_AND_WHITE_LIST_ACTION @"http/crm/saveBlackAndWhiteList.do"
//---黑白名单---//

//--外呼线路--//
///获取外呼线路状态
#define LLC_GET_OUTBOUND_ROUTE_TYPE_ACTION @"http/crm/findOutboundRouteType.do"
///编辑外呼线路状态
#define LLC_EDIT_OUTBOUND_ROUTE_TYPE_ACTION @"http/crm/updateOutboundRouteType.do"
//--外呼线路--//


//---漏挂短信---///
///获取短信设置状态
#define LLC_GET_SMS_SETINFO_ACTION @"http/crm/findSmsSet.do"
///编辑短信设置状态
#define LLC_EDID_SMS_SETINFO_ACTION @"http/crm/saveSmsSet.do"
//---漏挂短信---///

///--------旧接口--------///



///---------------1.2.9新增接口---------------///

///获取销售机会列表
#define LLC_GET_SALE_OPPORTUNITY_ACTION @"http/crm/getSaleOpportunityList.do"
///获取销售机会详情
#define LLC_GET_SALE_OPPORTUNITY_DETAILS_ACTION @"http/crm/saleOpportunityDetail.do"
///新增/编辑销售机会
#define LLC_SAVE_SALE_OPPORTUNITY_ACTION @"http/crm/saveSaleOpportunity.do"
///删除销售机会
#define LLC_DELETE_SALE_OPPORTUNITY_ACTION @"http/crm/deleteSaleOpportunity.do"


///获取售后服务列表
#define LLC_GET_AFTER_SERVICE_ACTION @"http/crm/getAfterServiceList.do"
///获取售后服务详情
#define LLC_GET_AFTER_SERVICE_DETAILS_ACTION @"http/crm/afterServiceDetail.do"
///新增/编辑售后服务
#define LLC_SAVE_AFTER_SERVICE_ACTION @"http/crm/saveAfterService.do"
///删除售后服务
#define LLC_DELETE_AFTER_SERVICE_ACTION @"http/crm/deleteAfterService.do"


///获取合同列表
#define LLC_GET_CONTRACT_ACTION @"http/crm/getContractList.do"
///获取合同详情
#define LLC_GET_CONTRACT_DETAILS_ACTION @"http/crm/contractDetail.do"
///新增/编辑合同
#define LLC_SAVE_CONTRACT_ACTION @"http/crm/saveContract.do"
///删除合同
#define LLC_DELETE_CONTRACT_ACTION @"http/crm/deleteContract.do"
///初始化合同
#define LLC_INIT_CONTRACT_ACTION @"http/crm/initContract.do"


///获订单列表
#define LLC_GET_ORDER_ACTION @"http/crm/getOrderList.do"
///获取订单详情
#define LLC_GET_ORDER_DETAILS_ACTION @"http/crm/orderDetail.do"
///新增/编辑订单
#define LLC_SAVE_ORDER_ACTION @"http/crm/saveOrder.do"
///删除订单
#define LLC_DELETE_ORDER_ACTION @"http/crm/deleteOrder.do"
///初始化订单
#define LLC_INIT_ORDER_ACTION @"http/crm/initOrder.do"


///查看座席状态
#define LLC_GET_SIT_STATUS_ACTION @"http/sitSet/querySiteStatus.do"


///获炫铃列表
#define LLC_GET_RING_ACTION @"http/crm/getRingList.do"
///新增/编辑炫铃
#define LLC_SAVE_RING_ACTION @"http/crm/saveRing.do"
///删除炫铃
#define LLC_DELETE_RING_ACTION @"http/crm/deleteRing.do"
///初始化炫铃
#define LLC_INIT_RING_ACTION @"http/crm/initRing.do"


///初始化默认设置
#define LLC_INIT_DEFAULT_SETTING_ACTION @"http/crm/initDefaultSetting.do"
///修改默认设置
#define LLC_SAVE_DEFAULT_SETTING_ACTION @"http/crm/saveDefaultSetting.do"


///新增标签
#define LLC_SAVE_CUSTOMER_STATEFLAG_ACTION @"http/crm/saveCustomerStateFlag.do"
///删除标签
#define LLC_DELETE_CUSTOMER_STATEFLAG_ACTION @"http/crm/deleteCustomerStateFlag.do"


///新增/编辑客户来源
#define LLC_SAVE_CUSTOMER_SOURCE_ACTION @"http/crm/saveCustomerSource.do"
///删除客户来源
#define LLC_DELETE_CUSTOMER_SOURCE_ACTION @"http/crm/deleteCustomerSource.do"


///新增/编辑客户类型
#define LLC_SAVE_CUSTOMER_TYPE_ACTION @"http/crm/saveCustomerType.do"
///删除客户类型
#define LLC_DELETE_CUSTOMER_TYPE_ACTION @"http/crm/deleteCustomerType.do"


///新增/编辑联系人类型
#define LLC_SAVE_LINKMAN_TYPE_ACTION @"http/crm/saveLinkManType.do"
///删除联系人类型
#define LLC_DELETE_LINKMAN_TYPE_ACTION @"http/crm/deleteLinkManType.do"


///获取销售字典
#define LLC_GET_SALE_DICTIONARY_ACTION @"http/crm/getSaleDictionary.do"


///新增/编辑销售类型
#define LLC_SAVE_SALE_TYPE_ACTION @"http/crm/saveSaleType.do"
///删除销售类型
#define LLC_DELETE_SALE_TYPE_ACTION @"http/crm/deleteSaleType.do"


///新增/编辑销售阶段
#define LLC_SAVE_SALE_STAGE_ACTION @"http/crm/saveSaleStage.do"
///删除销售阶段
#define LLC_DELETE_SALE_STAGE_ACTION @"http/crm/deleteSaleStage.do"


///新增/编辑销售状态
#define LLC_SAVE_SALE_STATUS_ACTION @"http/crm/saveSaleStatus.do"
///删除销售状态
#define LLC_DELETE_SALE_STATUS_ACTION @"http/crm/deleteSaleStatus.do"


///获取售后字典
#define LLC_GET_AFTER_SERVICE_DICTIONARY_ACTION @"http/crm/getAfterServiceDictionary.do"


///新增/编辑售后状态
#define LLC_SAVE_AFTER_SERVICE_STATUS_ACTION @"http/crm/saveAfterServiceStatus.do"
///删除售后状态
#define LLC_DELETE_AFTER_SERVICE_STATUS_ACTION @"http/crm/deleteAfterServiceStatus.do"


///新增/编辑售后类型
#define LLC_SAVE_AFTER_SERVICE_TYPE_ACTION @"http/crm/saveAfterServiceType.do"
///删除售后类型
#define LLC_DELETE_AFTER_SERVICE_TYPE_ACTION @"http/crm/deleteAfterServiceType.do"



///初始化导航
#define LLC_INIT_NAVIGATION_ACTION @"http/sitSet/initNavigation.do"
///获取导航详情
#define LLC_GET_NAVIGATION_DETAILS_ACTION @"http/sitSet/getNavigationDetail.do"
///新建/编辑导航
#define LLC_ADD_NAVIGATION_ACTION @"http/sitSet/addNavigation.do"
///座席排序
#define LLC_SORT_NAVIGATION_SIT_ACTION @"http/sitSet/seatSort.do"
///获取当前导航的下级导航列表
#define LLC_GET_CUR_NAVIGATION_CHILDNAVIGATION_ACTION @"http/sitSet/getNavigationList.do"
///获取当前导航的座席列表
#define LLC_GET_CUR_NAVIGATION_SITS_ACTION @"http/sitSet/getNavigationSeatList.do"

///删除导航
#define LLC_DELETE_NAVIGATION_ACTION @"http/sitSet/deleteNavigation.do"
///编辑导航
#define LLC_EDIT_NAVIGATION_ACTION @"http/sitSet/editNavigation.do"

///初始化地区
#define LLC_INIT_AREA_ACTION @"http/sitSet/initArea.do"


///编辑座席地区策略
#define LLC_EDIT_NAVIGATION_SIT_AREA_ACTION  @"http/sitSet/editSeatAreaStrategy.do"
///编辑座席时间策略
#define LLC_EDIT_NAVIGATION_SIT_TIME_ACTION  @"http/sitSet/editSeatDateStrategy.do"

///编辑导航地区策略
#define LLC_EDIT_NAVIGATION_AREA_ACTION  @"http/sitSet/editNavigationAreaStrategy.do"
///编辑导航时间策略
#define LLC_EDIT_NAVIGATION_TIME_ACTION  @"http/sitSet/editNavigationDateStrategy.do"

///编辑座席的等待时长
#define LLC_EDIT_SEAT_WAIT_DURATION_ACTION  @"http/sitSet/editSeatWaitDuration.do"

///获取当前座席的时间策略接口
#define LLC_GET_SEAT_TIME_STRATEGY_ACTION  @"http/sitSet/getSeatTimeStrategy.do"
///获取当前座席的地区策略接口.
#define LLC_GET_SEAT_AREA_STRATEGY_ACTION  @"http/sitSet/getSeatAreaStrategy.do"

///获取是否开通IVRivrStatus
///(ivr是否开通：1-是，0-否)
///ringStatus(彩铃是否开通：1-是，0-否)
#define LLC_GET_IVR_STATUS_ACTION  @"http/sitSet/qureyIvrStatus.do"
///编辑IVR未开通情况下的导航
#define LLC_EDIT_NAVIGATION_IVR_ACTION  @"http/sitSet/uppdateIvrSet.do"


///---------------1.2.9新增接口---------------///


///---------------1.3.0新增接口---------------///
//startTime
//endTime
#define LLC_GET_CENTER_CONSUMPTION_ACTION  @"http/query/qureyCenterConsumption.do"
#define LLC_GET_CENTER_RECHARGE_ACTION  @"http/query/qureyCenterRecharge.do"
#define LLC_GET_400PACKAGE_CONSUMPTION_ACTION  @"http/query/qureyPackageConsumption.do"
#define LLC_GET_400PACKAGE_RECHARGE_ACTION  @"http/query/qureyPackageRecharge.do"

///---------------1.3.0新增接口---------------///



///---------------3.0.0新增接口---------------///
///新建导航(最后一层)
#define LLC_ADD_FINAL_NAVIGATION_ACTION @"http/sitSet/addFinalNavigation.do"
///批量查询坐席接口 pageNo
#define LLC_QUERY_BATCH_SEATS_ACTION @"http/sitSet/querySeatList.do"
///批量添加坐席接口  navigationId   sitIds(,)
#define LLC_ADD_BATCH_SEATS_ACTION @"http/sitSet/batchAddSeats.do"

///删除当前导航的子导航及其关联的坐席  navigationId
#define LLC_DELETE_NAVIGATION_CHILD_SIT_ACTION @"http/sitSet/deleteNavigationAndRemoveSeat.do"
///删除当前导航的坐席  navigationId
#define LLC_DELETE_NAVIGATION_SIT_ACTION @"http/sitSet/batchRemoveSeats.do"
///编辑导航
#define LLC_EDIT_NAVIGATION_NEW_ACTION @"http/sitSet/editNavigation2.do"

///---------------3.0.0新增接口---------------///



@interface InterfacesAction : NSObject


@end
