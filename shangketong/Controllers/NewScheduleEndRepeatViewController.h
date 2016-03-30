//
//  NewScheduleEndRepeatViewController.h
//  shangketong
//
//  Created by sungoin-zjp on 15-8-5.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XLFormDescriptor.h>
#import <XLForm.h>
@interface NewScheduleEndRepeatViewController : XLFormViewController<XLFormRowDescriptorViewController, XLFormRowDescriptorPopoverViewController>

///修改日程详情重复事件  ‘update-schedule’
@property(nonatomic,strong) NSString *flagOfPlanUpdate;
@property (nonatomic, strong) XLFormRowDescriptor *rowDescriptor;
///日程详情  修改重复事件
@property (nonatomic,strong) NSMutableDictionary *dicPlanInfo;
///重复类型
@property (nonatomic, assign) NSInteger repeatType;
@property (nonatomic, copy) void(^valueDateBlock)();

@end
