//
//  XLFTaskDetailViewController.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/12.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "XLFormViewController.h"

@interface XLFTaskDetailViewController : XLFormViewController

@property (nonatomic, strong) NSString *uid;
@property (nonatomic, copy) void(^RefreshTaskListBlock)();

#pragma 编辑任务详情接口
- (void)editOneTaskOfDetail:(NSString *)flagForMember withRowDestriptor:(XLFormRowDescriptor *)rowDestriptor;
@end
