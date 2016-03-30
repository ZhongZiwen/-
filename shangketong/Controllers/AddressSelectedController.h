//
//  AddressSelectedController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/29.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "AddressBookBaseController.h"
#import <XLFormDescriptor.h>

@class AddressBook;

@interface AddressSelectedController : AddressBookBaseController<XLFormRowDescriptorViewController, XLFormRowDescriptorPopoverViewController>

@property (copy, nonatomic) void(^selectedBlock)(AddressBook*);

///控制返回动作逻辑判断
@property (copy, nonatomic) NSString *flagForPopViewAnimation;

@property (copy, nonatomic) NSString *activityRecBtnImage;
@property (copy, nonatomic) void(^activityRecBlock)(NSArray*);
@end
