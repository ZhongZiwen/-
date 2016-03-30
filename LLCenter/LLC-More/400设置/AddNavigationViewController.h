//
//  AddNavigationViewController.h
//  lianluozhongxin
//  新增导航
//  Created by sungoin-zjp on 15-10-21.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AppsBaseViewController.h"


@interface AddNavigationViewController : AppsBaseViewController

///上级导航Id(如果是根导航,则为@"")
@property(nonatomic,strong) NSString *navigationId;
///上级导航name()
@property(nonatomic,strong) NSString *navigationName;
///当前导航是否有开再下一级导航的权限 yes no
@property(nonatomic,strong) NSString *childNavigationHasChild;
///分流还是按键(0-按键进入,1-分流进入)
@property(nonatomic,assign)EnterNavigationWay enterNavigationWay;
///下级按键长度
@property(nonatomic,assign)NSInteger childNavigationKeyLength;

///刷新导航列表
@property (nonatomic, copy) void (^NotifyNavigationList)(void);

@end
