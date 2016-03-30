//
//  EditNavigationSeatViewController.h
//  lianluozhongxin
//  编辑导航
//  Created by sungoin-zjp on 15-10-26.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AppsBaseViewController.h"

@interface EditNavigationSeatViewController : AppsBaseViewController

///是否为根导航  yes  no  根导航（导航名称不可编辑-没有座席提示音-没有导航按键）
@property(nonatomic,strong) NSString *isRootNavigation;
///当前导航的座席列表
@property(nonatomic,strong) NSArray *sourNavigationSeatsOld;
///导航信息
@property(nonatomic,strong) NSDictionary *detail;
///分流还是按键(0-按键进入,1-分流进入)
@property(nonatomic,assign)EnterNavigationWay enterNavigationWay;
///当前导航的下级导航是否有开再下一级导航的权限 yes no
@property(nonatomic,strong) NSString *childNavigationHasChild;
///接听策略  (0-顺序接听,1-随机接听,2-平均接听)
@property(nonatomic,assign) ListenStrategy listenStrategy;
///当前按键长度
@property(nonatomic,assign)NSInteger curNavigationKeyLength;
///刷新导航列表
@property (nonatomic, copy) void (^NotifyNavigationList)(BOOL isBack);

@end
