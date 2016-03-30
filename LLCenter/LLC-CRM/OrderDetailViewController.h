//
//  OrderDetailViewController.h
//  lianluozhongxin
//  订单详情
//  Created by sungoin-zjp on 15-10-15.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AppsBaseViewController.h"

@interface OrderDetailViewController : AppsBaseViewController

@property(strong,nonatomic)NSString *orderId;
@property(strong,nonatomic) NSString *customerId;
///联系人 用以填充收货人
@property(strong,nonatomic) NSArray *arrayAllLinkMan;
///地址信息
@property(strong,nonatomic) NSString *customer_address;
///刷新订单列表
@property (nonatomic, copy) void (^NotifyOrderList)(void);


@end
