//
//  TaskViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/4/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

typedef NS_ENUM(NSInteger, TaskViewType) {
    TaskViewTypeNormal = 0,  //办公模块进入任务
    TaskViewTypeActivity = 1 //市场活动
};

@interface TaskViewController : BaseViewController

@property (nonatomic, assign) TaskViewType flag_type;
@end
