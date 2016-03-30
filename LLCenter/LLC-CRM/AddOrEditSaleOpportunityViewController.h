//
//  AddOrEditSaleOpportunityViewController.h
//  lianluozhongxin
//  新增、编辑销售机会
//  Created by sungoin-zjp on 15-10-13.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AppsBaseViewController.h"

@interface AddOrEditSaleOpportunityViewController : AppsBaseViewController

///新增/编辑  add  edit
@property(strong,nonatomic) NSString *actionType;
@property(strong,nonatomic) NSDictionary *detail;
@property(strong,nonatomic) NSString *customerId;

///刷新销售机会列表
@property (nonatomic, copy) void (^NotifySaleOpportunitysList)(void);
///刷新详情
@property (nonatomic, copy) void (^NotifySaleOpportunitysDetail)(void);
@end
