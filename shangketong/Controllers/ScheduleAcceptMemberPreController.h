//
//  ScheduleAcceptMemberPreController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/8/17.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ExportAddress;

@interface ScheduleAcceptMemberPreController : UIViewController

@property (strong, nonatomic) ExportAddress *sourceModel;
@property (strong, nonatomic) NSMutableDictionary *scheduleSourceDict;
@property (copy, nonatomic) void(^refreshBlock)(void);
@end
