//
//  ApprovalListViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/30.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "BaseViewController.h"

@interface ApprovalListViewController : BaseViewController

@property (copy, nonatomic) NSString *requestPath;
@property (copy, nonatomic) void(^refreshBlock)(void);

@end
