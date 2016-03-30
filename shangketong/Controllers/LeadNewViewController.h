//
//  LeadNewViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/9/22.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "XLFormBaseViewController.h"

@interface LeadNewViewController : XLFormBaseViewController

@property (strong, nonatomic) NSMutableDictionary *params;
@property (assign, nonatomic) BOOL isScanning;
@property (copy, nonatomic) void(^refreshBlock)(void);
@end
