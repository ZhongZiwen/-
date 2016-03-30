//
//  WorkGroupRecordViewController.h
//  shangketong
//  工作圈动态记录、我的动态、我的收藏
//  Created by sungoin-zjp on 15-6-11.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
typedef NS_ENUM(NSInteger, PushControllerType) {
    PushControllerTypeActivity = 201,  //市场活动
    PushControllerTypeClue = 202,  //销售线索
    PushControllerTypeCustomer = 203,  //客户
    PushControllerTypeContract = 204,  //联系人
    PushControllerTypeOpportunity = 205,   //销售机会
    PushControllerTypeGroup = 1001,   //群组
    PushControllerTypeDepartment = 1002 //部门
};

@interface WorkGroupRecordViewController : BaseViewController

@property(strong,nonatomic) UITableView *tableviewWorkGroup;
@property(strong,nonatomic) NSMutableArray *arrayWorkGroup;

///首页 工作圈 homeworkzone 工作圈 workzone  我的动态feed   我的收藏favorite
///部门 departmentfeed  群组  groupfeed
@property(strong,nonatomic) NSString *typeOfView;

////部门、群组ID
@property (nonatomic, assign) long long parentId;
///部门、群组名称
@property (nonatomic,strong) NSString *departmentOrGroup;
@property (nonatomic, assign) PushControllerType sourceType;


@end
