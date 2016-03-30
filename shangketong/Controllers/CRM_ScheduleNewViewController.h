//
//  CRM_ScheduleNewViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/29.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "XLFormViewController.h"

@interface CRM_ScheduleNewViewController : XLFormViewController

@property (copy, nonatomic) NSString *requestPath;
@property (copy, nonatomic) void(^refreshBlock)(void);
@end
