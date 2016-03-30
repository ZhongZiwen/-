//
//  XLFormBaseViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/12/22.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "XLFormViewController.h"
#import <XLForm.h>
#import "ColumnModel.h"
#import "ColumnSelectModel.h"

@interface XLFormBaseViewController : XLFormViewController

@property (strong, nonatomic) NSMutableArray *sourceArray;
@property (strong, nonatomic) NSNumber *customerId;

- (void)configXLForm;
- (NSString*)jsonString;
@end
