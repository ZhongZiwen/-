//
//  DeleteSaleOpportunityViewController.h
//  lianluozhongxin
//  删除销售机会
//  Created by sungoin-zjp on 15-10-14.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AppsBaseViewController.h"

@interface DeleteSaleOpportunityViewController : AppsBaseViewController

@property(strong,nonatomic) NSArray *dataSourceOld;
///刷新销售机会列表
@property (nonatomic, copy) void (^NotifySaleOpportunitysList)(void);
@end
