//
//  RegisterNewCompanyViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/12/4.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "XLFormViewController.h"

@interface RegisterNewCompanyViewController : XLFormViewController

@property (copy, nonatomic) NSString *account;
@property (assign, nonatomic) BOOL isFirstRegister;
@property (assign, nonatomic) BOOL isEmailRegister;
@end
