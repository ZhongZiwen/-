//
//  PlanViewController.h
//  DemoMapViewPOI
//  日程
//  Created by sungoin-zjp on 15-5-12.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JTCalendar.h"
#import "BaseViewController.h"

@interface PlanViewController : BaseViewController<JTCalendarDataSource,UITableViewDataSource,UITableViewDelegate>

@property(strong,nonatomic)JTCalendarMenuView *calendarMenuView;
@property(strong,nonatomic)JTCalendarContentView *calendarContentView;
@property(strong,nonatomic)NSLayoutConstraint *calendarContentViewHeight;
@property (strong, nonatomic) JTCalendar *calendar;

@property (strong, nonatomic) UITableView *tableviewContent;

///默认参与人信息
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, strong) NSString *userIcon;
@property (nonatomic, strong) NSString *userName;
// 0:当前用户   1:联系人
@property (nonatomic, assign) NSInteger flagFromWhereIntoPlan;
@property (nonatomic, strong) NSString *dateStr; //时间
@end
