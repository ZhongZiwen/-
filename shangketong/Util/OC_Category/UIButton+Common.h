//
//  UIButton+Common.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Common)

+ (UIButton *)buttonWithTitle:(NSString *)title titleColor:(UIColor *)color;
+ (UIButton *)buttonWithTitle_ForNav:(NSString *)title;
+ (UIButton *)buttonWithUserStyle;
- (void)userNameStyle;
- (void)frameToFitTitle;
- (void)setUserTitle:(NSString *)aUserName;
- (void)setUserTitle:(NSString *)aUserName font:(UIFont *)font maxWidth:(CGFloat)maxWidth;

@end
