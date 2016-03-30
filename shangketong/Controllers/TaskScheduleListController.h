//
//  TaskScheduleListController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/29.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "BaseViewController.h"

@interface TaskScheduleListController : BaseViewController

@property (copy, nonatomic) NSString *requestPath;
@property (copy, nonatomic) NSString *task_createPath;
@property (copy, nonatomic) NSString *schedule_createPath;
@property (copy, nonatomic) void(^refreshBlock)(void);
@end
