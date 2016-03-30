//
//  DeleteOrderViewController.h
//  lianluozhongxin
//  删除订单
//  Created by sungoin-zjp on 15-10-15.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AppsBaseViewController.h"

@interface DeleteOrderViewController : AppsBaseViewController

@property(strong,nonatomic) NSArray *dataSourceOld;
///刷新订单列表
@property (nonatomic, copy) void (^NotifyOrderList)(void);

@end
