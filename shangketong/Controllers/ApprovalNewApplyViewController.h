//
//  ApprovalNewApplyViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/7/31.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "XLFormViewController.h"

@interface ApprovalNewApplyViewController : XLFormViewController

@property (nonatomic, assign) NSInteger applyId;
@property (nonatomic, assign) NSInteger applyTypeId;
@property (nonatomic, copy) void(^refreshBlock)();
@end
