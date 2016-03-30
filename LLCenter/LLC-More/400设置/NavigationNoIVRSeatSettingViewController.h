//
//  NavigationNoIVRSeatSettingViewController.h
//  lianluozhongxin
//  导航设置-未开通IVR  只有一层  即包含座席列表
//  Created by sungoin-zjp on 15-10-26.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AppsBaseViewController.h"

@interface NavigationNoIVRSeatSettingViewController : AppsBaseViewController

///ringStatus(彩铃是否开通：1-是，0-否)
@property(nonatomic,assign)NSInteger  ringStatus;

@end
