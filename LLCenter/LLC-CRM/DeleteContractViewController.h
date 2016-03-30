//
//  DeleteContractViewController.h
//  lianluozhongxin
//   删除合同
//  Created by sungoin-zjp on 15-10-15.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AppsBaseViewController.h"

@interface DeleteContractViewController : AppsBaseViewController


@property(strong,nonatomic) NSArray *dataSourceOld;
///刷新合同列表
@property (nonatomic, copy) void (^NotifyContractList)(void);

@end
