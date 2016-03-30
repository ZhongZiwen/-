//
//  WorkReportDetailViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/8/9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "XLFormViewController.h"

@class WorkReportItem;

@interface WorkReportDetailViewController : XLFormViewController

@property (nonatomic, assign) NSInteger curIndex;
@property (nonatomic, strong) WorkReportItem *reportItem;

@property (nonatomic, copy) void(^refreshBlock)();
@end
