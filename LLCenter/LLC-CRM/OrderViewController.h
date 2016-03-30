//
//  OrderViewController.h
//  lianluozhongxin
//  订单
//  Created by sungoin-zjp on 15-10-15.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AppsBaseViewController.h"

@interface OrderViewController : AppsBaseViewController

///客户ID
@property(strong,nonatomic) NSString *customerId;

///联系人 用以填充收货人
@property(strong,nonatomic) NSArray *arrayAllLinkMan;
///地址信息
@property(strong,nonatomic) NSString *customer_address;

@end
