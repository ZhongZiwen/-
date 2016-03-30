//
//  LeadChangeToCustomerController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/11/11.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "XLFormViewController.h"

@interface LeadChangeToCustomerController : XLFormViewController

@property (copy, nonatomic) void(^changeSuccessBlock)(void);

@property (strong, nonatomic) NSNumber *id;
@end
