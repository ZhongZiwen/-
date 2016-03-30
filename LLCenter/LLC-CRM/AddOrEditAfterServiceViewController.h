//
//  AddOrEditAfterServiceViewController.h
//  lianluozhongxin
//  新增、编辑售后服务
//  Created by sungoin-zjp on 15-10-15.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AppsBaseViewController.h"

@interface AddOrEditAfterServiceViewController : AppsBaseViewController

///新增/编辑  add  edit
@property(strong,nonatomic) NSString *actionType;
@property(strong,nonatomic) NSDictionary *detail;
@property(strong,nonatomic) NSString *customerId;


///刷新售后服务列表
@property (nonatomic, copy) void (^NotifyAfterServiceList)(void);
///刷新详情
@property (nonatomic, copy) void (^NotifyAfterServiceDetail)(void);

@end
