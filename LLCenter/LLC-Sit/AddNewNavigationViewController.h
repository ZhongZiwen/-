//
//  AddNewNavigationViewController.h
//  
//
//  Created by sungoin-zjp on 16/1/6.
//
//

#import <UIKit/UIKit.h>

@interface AddNewNavigationViewController : BaseViewController

///分流还是按键(0-按键进入,1-分流进入)
@property(nonatomic,assign)EnterNavigationWay enterNavigationWay;
///下级按键长度
@property(nonatomic,assign)NSInteger childNavigationKeyLength;

///导航信息
@property(nonatomic,strong)NSDictionary *navigationDic;


///刷新列表
@property (nonatomic, copy) void (^NotifyNavigationList)(void);

@end
