//
//  SortNavigationSeatsViewController.h
//  lianluozhongxin
//  上下滑动排序
//  Created by sungoin-zjp on 15-10-27.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AppsBaseViewController.h"

@interface SortNavigationSeatsViewController : AppsBaseViewController

@property(strong,nonatomic) NSArray *dataSourceOld;
@property(strong,nonatomic) NSString *navitaionId;

///刷新座席列表
@property (nonatomic, copy) void (^NotifyNavigationSitList)(NSMutableArray *array);

@end
