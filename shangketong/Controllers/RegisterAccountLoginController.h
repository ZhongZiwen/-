//
//  RegisterAccountLoginController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/12/4.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NameIdModel;

@interface RegisterAccountLoginController : UIViewController

@property (strong, nonatomic) NameIdModel *item;
@property (copy, nonatomic) NSString *accountName;
@property (assign, nonatomic) BOOL isCreateCompany;
@end
