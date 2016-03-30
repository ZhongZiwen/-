//
//  ExportAddressViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/5/6.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "AddressBookBaseController.h"
#import <XLFormDescriptor.h>

@interface ExportAddressViewController : AddressBookBaseController<XLFormRowDescriptorViewController, XLFormRowDescriptorPopoverViewController>

@property (strong, nonatomic) NSMutableArray *selectedArray;        // 已选的通讯人，在通讯录中要被排除
@property (assign, nonatomic) BOOL isActivityRecExport;
@property (copy, nonatomic) void(^valueBlock) (NSArray *array);
@end
