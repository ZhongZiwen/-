//
//  CRM_ContactNewViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/12/21.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "XLFormBaseViewController.h"

@interface CRM_ContactNewViewController : XLFormBaseViewController

@property (copy, nonatomic) NSString *requestInitPath;
@property (copy, nonatomic) NSString *requestScanfPath;
@property (copy, nonatomic) NSString *requestSavePath;
@property (assign, nonatomic) BOOL isScanning;
@property (copy, nonatomic) void(^refreshBlock)(void);
@end
