//
//  CRMDetail.h
//  shangketong
//
//  Created by sungoin-zbs on 16/1/6.
//  Copyright © 2016年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ValueIdModel.h"
#import "DetailStaffModel.h"
#import "User.h"
#import "OpportunityStage.h"
#import "ColumnModel.h"
#import "Record.h"
#import "FileModel.h"
#import "Code.h"
#import "PopoverItem.h"

@interface CRMDetail : NSObject

@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) NSNumber *customId;       // 用于修改或编辑
@property (strong, nonatomic) NSNumber *focus;          // 是否被关注
@property (strong, nonatomic) NSNumber *staffLevel;     // 当前查看者是否有修改权限  0其他 1所有者 2负责员工 3相关员工，1和2有资料修改权限
@property (strong, nonatomic) NSNumber *saleLeadNum;    // 销售线索总数
@property (strong, nonatomic) NSNumber *customerNum;    // 客户总数
@property (strong, nonatomic) NSNumber *contactNum;     // 联系人总数
@property (strong, nonatomic) NSNumber *saleChanceNum;  // 销售机会
@property (strong, nonatomic) NSNumber *taskScheduleNum;// 日程任务总数
@property (strong, nonatomic) NSNumber *productNum;     // 产品
@property (strong, nonatomic) NSNumber *approvalNum;    // 审批总数
@property (strong, nonatomic) NSNumber *fileNum;        // 文件总数
@property (copy, nonatomic) NSString *name;             // 名称
@property (copy, nonatomic) NSString *position;         // 地址
@property (copy, nonatomic) NSString *phone;            // 电话号码
@property (copy, nonatomic) NSString *mobile;           // 手机号码
@property (copy, nonatomic) NSString *email;            // 电邮
@property (strong, nonatomic) ValueIdModel *activityState;       // 活动状态
@property (strong, nonatomic) NSMutableArray *activityListArray; // 活动状态列表
@property (strong, nonatomic) NSMutableArray *staffsArray;       // 团队成员
@property (strong, nonatomic) NSMutableArray *codesArray;        // 权限码

@property (strong, nonatomic) NSMutableArray *followRecordArray; // 跟进记录数组
@property (strong, nonatomic) NSMutableArray *recordTypeArray;   // 活动类型数组
@property (strong, nonatomic) NSMutableArray *columnsArray;      // 详情资料数组
@property (strong, nonatomic) NSMutableArray *columnsShowArray;  // 显示的详细资料数组

// 市场活动
@property (strong, nonatomic) NSDate *startTime;        // 开始时间
@property (strong, nonatomic) NSDate *endTime;          // 结束时间
@property (strong, nonatomic) NSNumber *isMarketOpen;   // 是否开启会销模式（控制详情中客户是否显示 0 开启显示 1不显示）

// 销售线索
@property (strong, nonatomic) NSNumber *ownerId;        // 销售线索所有人
@property (copy, nonatomic) NSString *claimStatus;      // 1:自建 2:未领取 3:已领取 4:已转换 5:已废弃 6:已冻结 7:已签约（已领取的不能删除）
@property (strong, nonatomic) ValueIdModel *followState;  // 跟进状态
@property (strong, nonatomic) ValueIdModel *group;        // 所在线索池分组
@property (strong, nonatomic) NSMutableArray *followListArray;  // 跟进状态列表

// 客户

// 联系人
@property (strong, nonatomic) User *customer;           // 所属客户

// 销售机会
@property (strong, nonatomic) NSNumber *money;          // 预期金额
@property (strong, nonatomic) NSDate *billDate;         // 结单日期
@property (strong, nonatomic) OpportunityStage *currentStage; // 当前销售阶段
@property (strong, nonatomic) NSMutableArray *stageListArray; //销售阶段

// 团队成员，排序
- (void)configStaffArray:(NSArray*)array;
// 详细资料
- (void)configColumnsShowArray;
@end
