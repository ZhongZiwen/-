//
//  SaleOpportunityDetailViewController.h
//  lianluozhongxin
//  销售机会详情
//  Created by sungoin-zjp on 15-10-13.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AppsBaseViewController.h"

@interface SaleOpportunityDetailViewController : AppsBaseViewController

@property(strong,nonatomic)NSString *saleId;
@property(strong,nonatomic) NSString *customerId;

///刷新销售机会列表
@property (nonatomic, copy) void (^NotifySaleOpportunitysList)(void);

@end
