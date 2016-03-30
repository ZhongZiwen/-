//
//  DeleteRingViewController.h
//  lianluozhongxin
//  删除炫铃
//  Created by sungoin-zjp on 15-10-16.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AppsBaseViewController.h"

@interface DeleteRingViewController : AppsBaseViewController

@property(strong,nonatomic) NSArray *dataSourceOld;
///刷新炫铃列表
@property (nonatomic, copy) void (^NotifyRingList)(void);

@end
