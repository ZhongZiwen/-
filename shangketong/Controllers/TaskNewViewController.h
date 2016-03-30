//
//  TaskNewViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/11/29.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "XLFormViewController.h"

@interface TaskNewViewController : XLFormViewController

@property (copy, nonatomic) void(^refreshBlock)(void);
@end
