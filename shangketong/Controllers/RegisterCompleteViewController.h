//
//  RegisterompleteViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/5/8.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, AuthCodeType) {
    AuthCodeTypeRegister,
    AuthCodeTypeFindPassword
};

@interface RegisterCompleteViewController : UIViewController

@property (nonatomic, copy) NSString *inputStr;

@property (assign, nonatomic) AuthCodeType  authCodeType;
@property (assign, nonatomic) BOOL isEmailRegister;
@end
