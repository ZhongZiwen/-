//
//  ContractDetailViewController.h
//  lianluozhongxin
//  合同详情
//  Created by sungoin-zjp on 15-10-15.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AppsBaseViewController.h"

@interface ContractDetailViewController : AppsBaseViewController

@property(strong,nonatomic)NSString *contractId;
@property(strong,nonatomic) NSString *customerId;

///刷新合同列表
@property (nonatomic, copy) void (^NotifyContractList)(void);

@end
