//
//  PlanAdvancedSearchViewController.h
//  DemoMapViewPOI
//  日程-高级检索
//  Created by sungoin-zjp on 15-5-13.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlanAdvancedSearchViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property(strong,nonatomic) UITableView *tableviewPlanSearchOption;

///
@property(strong,nonatomic) NSString *strType;

@property (nonatomic, copy) void (^notifyScheduleDataBlock)(NSString *finish,NSString *task,NSString *xb,NSString *types);

@property(strong,nonatomic) NSString *isFinish;
@property(strong,nonatomic) NSString *showTask;
@property(strong,nonatomic) NSString *showXB;
@property(strong,nonatomic) NSString *typeIds;

// 0:当前用户   1:联系人
@property (nonatomic, assign) NSInteger flagFromWhereIntoPlan;

@end
