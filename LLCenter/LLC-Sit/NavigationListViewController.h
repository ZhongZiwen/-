//
//  NavigationListViewController.h
//  导航列表
//
//  Created by sungoin-zjp on 16/1/6.
//
//

#import <UIKit/UIKit.h>

@interface NavigationListViewController : BaseViewController

///全部导航还是子导航
@property(nonatomic,strong) NSString *navigationType;
///已选择的导航
@property(nonatomic,strong) NSString *navigationSelectedIds;

@property (nonatomic, copy) void (^SelectNavigation)(NSString *strNames,NSString *strNavids);


///导航信息
@property(nonatomic,strong)NSDictionary *navigationDic;

@end
