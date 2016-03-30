//
//  WorkSelectContectsViewController.h
//  shangketong
//
//  Created by 蒋 on 15/12/31.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "AddressBookBaseController.h"

@interface WorkSelectContectsViewController : AddressBookBaseController<XLFormRowDescriptorViewController, XLFormRowDescriptorPopoverViewController>

@property (strong, nonatomic) NSMutableArray *selectedArray;        // 已选的通讯人，在通讯录中要被排除
@property (assign, nonatomic) BOOL isActivityRecExport;
@property (copy, nonatomic) void(^valueBlock) (NSArray *array);

@end
