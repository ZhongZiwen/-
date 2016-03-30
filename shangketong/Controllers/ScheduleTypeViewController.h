//
//  ScheduleTypeViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/8/11.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XLFormDescriptor.h>

@class ScheduleType;

@interface ScheduleTypeViewController : UIViewController<XLFormRowDescriptorViewController, XLFormRowDescriptorPopoverViewController>

@property (strong, nonatomic) ScheduleType *item;
@property (nonatomic, copy) void(^valueBlock)(id);
@end
