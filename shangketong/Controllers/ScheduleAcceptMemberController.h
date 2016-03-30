//
//  ScheduleAcceptMemberController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/8/17.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScheduleAcceptMemberController : UIViewController

@property (nonatomic, strong) NSMutableDictionary *scheduleSourceDict;
@property (nonatomic, copy) void(^updateBlock) (void);
@end
