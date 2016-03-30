//
//  AddCustomerViewController.h
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-9-10.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AppsBaseViewController.h"

@interface AddCustomerViewController : AppsBaseViewController


///刷新客户列表
@property (nonatomic, copy) void (^NotifyCustomerList)(void);

@end
