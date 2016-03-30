//
//  EditInfoViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/5/5.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@interface EditInfoViewController : BaseViewController
@property(strong,nonatomic) NSDictionary *userInfo;

@property(strong,nonatomic) UIImage *userIcon;
@property (nonatomic, copy) void (^UpdateUserInfosBlock)(NSDictionary *userInfo);

@end
