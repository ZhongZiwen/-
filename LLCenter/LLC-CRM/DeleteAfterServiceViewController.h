//
//  DeleteAfterServiceViewController.h
//  lianluozhongxin
//  删除售后服务
//  Created by sungoin-zjp on 15-10-15.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AppsBaseViewController.h"

@interface DeleteAfterServiceViewController : AppsBaseViewController

@property(strong,nonatomic) NSArray *dataSourceOld;
///刷新售后服务列表
@property (nonatomic, copy) void (^NotifyAfterServiceList)(void);

@end
