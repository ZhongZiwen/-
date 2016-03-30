//
//  AppsBaseViewController.h
//  GDPU_Bible
//
//  Created by Vescky on 13-5-31.
//  Copyright (c) 2013年 gdpuDeveloper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

///(0-按键进入,1-分流进入)
typedef NS_ENUM(NSInteger, EnterNavigationWay) {
    EnterNavWayByKeyNum,
    EnterNavWayShunt
};

///(0-顺序接听,1-随机接听,2-平均接听)
typedef NS_ENUM(NSInteger, ListenStrategy) {
    ListenStrategySequence,
    ListenStrategyRandom,
    ListenStrategyAverage
};

@interface AppsBaseViewController : BaseViewController {
    bool isSubView;
}

- (void)customBackButton;
- (void)customBackButtonWithTitle:(NSString *)title;

- (void)customNavigationBarRightButtonWithImageName:(NSString*)imgName;
- (void)customNavigationBarRightButtonWithTitleName:(NSString*)titleName;

-(void)setFlagOfSubView;
@end
