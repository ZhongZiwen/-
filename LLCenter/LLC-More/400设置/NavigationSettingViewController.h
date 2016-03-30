//
//  NavigationSettingViewController.h
//  lianluozhongxin
//  导航设置
//  Created by sungoin-zjp on 15-10-20.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AppsBaseViewController.h"

///(0-下级导航,1-坐席列表,2未知)
typedef NS_ENUM(NSInteger, NavigationViewType) {
    NavigationViewTypeNextChild,
    NavigationViewTypeSitList,
    NavigationViewTypeUnknown
};

@interface NavigationSettingViewController : AppsBaseViewController

///导航Id(如果是根导航,则为@"")
@property(nonatomic,strong) NSString *navigationId;

///当前导航是否设置了下级导航 如果没有 则显示其对应的坐席列表
@property(nonatomic,assign)NavigationViewType curNavigationViewType;


///是否为根导航  yes  no  根导航（导航名称不可编辑-没有座席提示音-没有导航按键）
@property(nonatomic,strong) NSString *isRootNavigation;
///分流还是按键(0-按键进入,1-分流进入) 进入下级导航的方式
@property(nonatomic,assign)EnterNavigationWay nextEnterNavigationWay;

///分流还是按键(0-按键进入,1-分流进入) 当前导航的进入方式
@property(nonatomic,assign)EnterNavigationWay curEnterNavigationWay;

///下级导航是否有开启下级导航的权限
@property(nonatomic,strong) NSString *childNavigationHasChild;
///当前导航是否有开启下级导航的权限
@property(nonatomic,strong) NSString *curChildNavigationHasChild;

///当前导航的是否设置了下级导航0-是，1-否
@property(nonatomic,strong) NSString *navigationsetChild;

///当前按键长度
@property(nonatomic,assign)NSInteger curNavigationKeyLength;
///下级按键长度
@property(nonatomic,assign)NSInteger childNavigationKeyLength;
///刷新导航
@property (nonatomic, copy) void (^NotifyNavigationListBlock)(void);

@end
