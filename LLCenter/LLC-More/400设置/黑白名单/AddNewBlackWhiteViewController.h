//
//  AddNewBlackWhiteViewController.h
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-9-16.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AppsBaseViewController.h"

@interface AddNewBlackWhiteViewController : AppsBaseViewController

///用来标记是黑名单还是白名单
@property(nonatomic,assign) NSInteger indexOfBW;
///刷新黑白名单列表
@property (nonatomic, copy) void (^NotifyBlackWhiteList)(void);

@end
