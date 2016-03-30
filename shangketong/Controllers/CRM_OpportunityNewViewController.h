//
//  CRM_OpportunityNewViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/12/21.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "XLFormBaseViewController.h"

@interface CRM_OpportunityNewViewController : XLFormBaseViewController

@property (copy, nonatomic) NSString *requestInitPath;
@property (copy, nonatomic) NSString *requestSavePath;
@property (copy, nonatomic) void(^refreshBlock)(void);
@end
