//
//  RegisterAccountListController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/12/4.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterAccountListController : UIViewController

@property (strong, nonatomic) NSMutableArray *sourceArray;
@property (copy, nonatomic) NSString *accountName;
@property (assign, nonatomic) BOOL isEmailRegister;
@end
