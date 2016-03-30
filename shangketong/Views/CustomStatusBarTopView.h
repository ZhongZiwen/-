//
//  CustomStatusBarTopView.h
//  shangketong
//
//  Created by sungoin-zjp on 15-6-4.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomStatusBarTopView : UIWindow

@property (nonatomic, strong) UILabel *messageLabel;
- (void)showTopViewMessage:(NSString *)message;
- (void)hide;
@end
