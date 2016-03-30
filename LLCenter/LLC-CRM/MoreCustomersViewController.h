//
//  MoreCustomersViewController.h
//  lianluozhongxin
//  客户管理-更多
//  Created by sungoin-zjp on 15-7-6.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AppsBaseViewController.h"

@interface MoreCustomersViewController : AppsBaseViewController

@property(strong,nonatomic) UITableView *tableviewCustomers;

@property(strong,nonatomic) NSArray *arrayAllLinkMan;
@property(nonatomic,strong) NSDictionary *cusDetails;

@property (nonatomic, copy) void (^RequestDataByLinkman)(NSDictionary *linkMan);

@property (nonatomic, copy) void (^NotifyLinkmanData)(void);

@end
