//
//  ApprovalDetailViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/8/2.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "XLFormViewController.h"

@class Approval;

@interface ApprovalDetailViewController : XLFormViewController

@property (nonatomic, strong) Approval *approval;
@property (nonatomic, copy) void(^refreshDataSource)(void);
@end
