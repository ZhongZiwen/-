//
//  EditNavigationNoIVRSeatViewController.h
//  lianluozhongxin
//  编辑导航
//  Created by sungoin-zjp on 15-10-26.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AppsBaseViewController.h"

@interface EditNavigationNoIVRSeatViewController : AppsBaseViewController

///当前导航的座席列表
@property(nonatomic,strong) NSArray *sourNavigationSeatsOld;
///导航信息
@property(nonatomic,strong) NSDictionary *detail;

///接听策略  (0-顺序接听,1-随机接听,2-平均接听)
@property(nonatomic,assign) ListenStrategy listenStrategy;

///ringStatus(彩铃是否开通：1-是，0-否)
@property(nonatomic,assign)NSInteger  ringStatus;


///刷新导航列表
@property (nonatomic, copy) void (^NotifyNavigationList)(void);

@end
