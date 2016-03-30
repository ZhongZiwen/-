//
//  NavigationDetailViewController.h
//  
//
//  Created by sungoin-zjp on 16/1/8.
//
//

#import <UIKit/UIKit.h>

@interface NavigationDetailViewController : BaseViewController

///分流还是按键(0-按键进入,1-分流进入)
@property(nonatomic,assign)EnterNavigationWay enterNavigationWay;
///当前按键长度
@property(nonatomic,assign)NSInteger curNavigationKeyLength;
///接听策略  (0-顺序接听,1-随机接听,2-平均接听)
@property(nonatomic,assign) ListenStrategy listenStrategy;
///当前导航的是否设置了下级导航0-是，1-否
@property(nonatomic,strong) NSString *navigationsetChild;
///当前导航的下级导航是否有开再下一级导航的权限 yes no
@property(nonatomic,strong) NSString *childNavigationHasChild;
///导航信息
@property(nonatomic,strong)NSDictionary *navigationDic;

///刷新坐席列表
@property (nonatomic, copy) void (^NotifySitListBlock)(void);


@end
