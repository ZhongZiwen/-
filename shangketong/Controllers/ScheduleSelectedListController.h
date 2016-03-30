//
//  ScheduleSelectedListController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/8/12.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XLFormRowDescriptor;

@interface ScheduleSelectedListController : UIViewController

@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) XLFormRowDescriptor *rowDescriptor;
@property (nonatomic, copy) void(^valueBlock)(NSDictionary *dict, NSInteger tag);

///修改日程详情重复事件  ‘update-schedule’
@property(nonatomic,strong) NSString *flagOfPlanUpdate;
@property (nonatomic,strong) NSMutableDictionary *dicPlanInfo;
@property (nonatomic, copy) void(^valueDateBlock)();
@end
