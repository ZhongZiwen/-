//
//  UIView+Common.h
//  shangketong
//
//  Created by sungoin-zbs on 15/5/8.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MBProgressHUD.h>
#import "EaseBlankPageView.h"

@interface UIView (Common)

- (void)doCircleFrame;
- (void)doNotCircleFrame;
- (void)doBorderWidth:(CGFloat)width color:(UIColor *)color cornerRadius:(CGFloat)cornerRadius;

- (void)addLineUp:(BOOL)hasUp andDown:(BOOL)hasDown;
- (void)addLineUp:(BOOL)hasUp andDown:(BOOL)hasDown andColor:(UIColor *)color;
- (void)removeViewWithTag:(NSInteger)tag;

- (void)setY:(CGFloat)y;
- (void)setX:(CGFloat)x;
- (void)setCenterX:(CGFloat)x;
- (void)setCenterY:(CGFloat)y;
- (void)setOrigin:(CGPoint)origin;
- (void)setHeight:(CGFloat)height;
- (void)setWidth:(CGFloat)width;
- (void)setSize:(CGSize)size;
+ (UIViewAnimationOptions)animationOptionsForCurve:(UIViewAnimationCurve)curve;

#pragma mark - LoadingView
@property (strong, nonatomic) MBProgressHUD *hud;
- (void)beginLoading;
- (void)endLoading;

#pragma mark - EaseBlankPageView
@property (strong, nonatomic) EaseBlankPageView *blankPageView;
- (void)configBlankPageWithTitle:(NSString*)title hasData:(BOOL)hasData hasError:(BOOL)hasError reloadButtonBlock:(void(^)(id sender))block;
@end
