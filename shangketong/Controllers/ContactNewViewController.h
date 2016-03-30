//
//  ContactNewViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/9/23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "XLFormBaseViewController.h"

@interface ContactNewViewController : XLFormBaseViewController

@property (copy, nonatomic) NSString *requestInitPath;
@property (copy, nonatomic) NSString *requestAddPath;
@property (copy, nonatomic) NSString *requestScanningPath;
@property (strong, nonatomic) NSMutableDictionary *params;
@property (assign, nonatomic) BOOL isScanning;
@property (copy, nonatomic) void(^refreshBlock)(void);
@end
