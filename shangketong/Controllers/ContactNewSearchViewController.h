//
//  ContactNewSearchViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/12/1.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XLFormDescriptor.h>

@class Customer;

@interface ContactNewSearchViewController : UIViewController<XLFormRowDescriptorViewController, XLFormRowDescriptorPopoverViewController>

@property (copy, nonatomic) void(^selectedBlock)(Customer*);
@end
