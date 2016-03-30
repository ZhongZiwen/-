//
//  AfterServiceDetailViewController.h
//  lianluozhongxin
//  售后详情
//  Created by sungoin-zjp on 15-10-15.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AppsBaseViewController.h"

@interface AfterServiceDetailViewController : AppsBaseViewController

@property(strong,nonatomic)NSString *serviceId;
@property(strong,nonatomic) NSString *customerId;

///刷新售后服务列表
@property (nonatomic, copy) void (^NotifyAfterServiceList)(void);

@end
