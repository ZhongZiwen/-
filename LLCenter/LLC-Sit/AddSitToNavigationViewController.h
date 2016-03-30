//
//  AddSitToNavigationViewController.h
//  添加坐席到导航（坐席列表）
//
//  Created by sungoin-zjp on 16/1/6.
//
//

#import <UIKit/UIKit.h>

@interface AddSitToNavigationViewController : BaseViewController


///导航id
@property(nonatomic,strong)NSString *navigationId;


///刷新坐席列表
@property (nonatomic, copy) void (^NotifySitListBlock)(void);

@end
