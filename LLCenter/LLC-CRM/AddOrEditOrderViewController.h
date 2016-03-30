//
//  AddOrEditOrderViewController.h
//  lianluozhongxin
//  新增、编辑订单
//  Created by sungoin-zjp on 15-10-15.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AppsBaseViewController.h"

@interface AddOrEditOrderViewController : AppsBaseViewController

///新增/编辑  add  edit
@property(strong,nonatomic) NSString *actionType;
@property(strong,nonatomic) NSDictionary *detail;
@property(strong,nonatomic) NSString *customerId;
///联系人 用以填充收货人
@property(strong,nonatomic) NSArray *arrayAllLinkMan;
///地址信息
@property(strong,nonatomic) NSString *customer_address;

///刷新订单列表
@property (nonatomic, copy) void (^NotifyOrderList)(void);
///刷新详情
@property (nonatomic, copy) void (^NotifyOrderDetail)(void);

@end
