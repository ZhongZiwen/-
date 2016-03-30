//
//  ScheduleDetailViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/8/8.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "XLFormViewController.h"

@interface ScheduleDetailViewController : XLFormViewController

@property (nonatomic, assign) NSInteger scheduleId;
@property (nonatomic, copy) void(^RefreshForPlanControllerBlock)();
@end
