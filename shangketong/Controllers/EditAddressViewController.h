//
//  EditAddressViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/9/11.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XLFormDescriptor.h>

@class ExportAddress, AddressBook;

@interface EditAddressViewController : UIViewController<XLFormRowDescriptorViewController, XLFormRowDescriptorPopoverViewController>

@property (strong, nonatomic) ExportAddress *sourceModel;
@property (copy, nonatomic) void(^refreshBlock)(NSArray*);
@property (copy, nonatomic) void(^addBlock)(AddressBook*);
@property (copy, nonatomic) void(^deleteBlock)(AddressBook*);

@property (copy, nonatomic) void(^newAddContactBlock)(NSArray *array);
@property (copy, nonatomic) void(^refreshContactBlock)();
@end
