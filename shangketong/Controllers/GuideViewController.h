//
//  GuideViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/4/22.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GuideViewController : UIViewController

///是否跳转到登陆页面   yes/no
@property (strong,nonatomic) NSString *flagToLoginView;
///登陆异常信息
@property(strong,nonatomic) NSString *errorDesc;

@end
