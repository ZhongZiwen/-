//
//  UIView+Common.m
//  shangketong
//
//  Created by sungoin-zbs on 15/5/8.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "UIView+Common.h"
#import <objc/runtime.h>

#define kTagLineView 1007

@implementation UIView (Common)
static char LoadingViewKey, BlankPageViewKey;

+ (UIView *)lineViewWithPointYY:(CGFloat)pointY{
    return [UIView lineViewWithPointYY:pointY andColor:[UIColor colorWithHexString:@"0xc8c7cc"]];
}

+ (UIView *)lineViewWithPointYY:(CGFloat)pointY andColor:(UIColor *)color{
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, pointY, kScreen_Width, 0.5)];
    lineView.backgroundColor = color;
    return lineView;
}

- (void)doCircleFrame {
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = self.frame.size.width/2;
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = [UIColor colorWithHexString:@"0xdddddd"].CGColor;
}
- (void)doNotCircleFrame {
    self.layer.cornerRadius = 0.0;
    self.layer.borderWidth = 0.0;
}

- (void)doBorderWidth:(CGFloat)width color:(UIColor *)color cornerRadius:(CGFloat)cornerRadius {
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = cornerRadius;
    self.layer.borderWidth = width;
    if (!color) {
        self.layer.borderColor = [UIColor colorWithHexString:@"0xdddddd"].CGColor;
    }else {
        self.layer.borderColor = color.CGColor;
    }
}

- (void)addLineUp:(BOOL)hasUp andDown:(BOOL)hasDown
{
    [self addLineUp:hasUp andDown:hasDown andColor:[UIColor colorWithHexString:@"0xc8c7cc"]];
}

- (void)addLineUp:(BOOL)hasUp andDown:(BOOL)hasDown andColor:(UIColor *)color
{
    [self removeViewWithTag:kTagLineView];
    if (hasUp) {
        UIView *upView = [UIView lineViewWithPointYY:0 andColor:color];
        upView.tag = kTagLineView;
        [self addSubview:upView];
    }
    if (hasDown) {
        UIView *downView = [UIView lineViewWithPointYY:CGRectGetMaxY(self.bounds)-0.5 andColor:color];
        downView.tag = kTagLineView;
        [self addSubview:downView];
    }
}

- (void)removeViewWithTag:(NSInteger)tag
{
    for (UIView *aView in [self subviews]) {
        if (aView.tag == tag) {
            [aView removeFromSuperview];
        }
    }
}

- (void)setY:(CGFloat)y{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}
- (void)setX:(CGFloat)x{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (void)setCenterX:(CGFloat)x {
    CGPoint center = self.center;
    center.x = x;
    self.center = center;
}

- (void)setCenterY:(CGFloat)y {
    CGPoint center = self.center;
    center.y = y;
    self.center = center;
}

- (void)setOrigin:(CGPoint)origin{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (void)setHeight:(CGFloat)height{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (void)setWidth:(CGFloat)width{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (void)setSize:(CGSize)size{
    CGRect frame = self.frame;
    frame.size.width = size.width;
    frame.size.height = size.height;
    self.frame = frame;
}

+ (UIViewAnimationOptions)animationOptionsForCurve:(UIViewAnimationCurve)curve
{
    switch (curve) {
        case UIViewAnimationCurveEaseInOut:
            return UIViewAnimationOptionCurveEaseInOut;
            break;
        case UIViewAnimationCurveEaseIn:
            return UIViewAnimationOptionCurveEaseIn;
            break;
        case UIViewAnimationCurveEaseOut:
            return UIViewAnimationOptionCurveEaseOut;
            break;
        case UIViewAnimationCurveLinear:
            return UIViewAnimationOptionCurveLinear;
            break;
    }
    
    return kNilOptions;
}

- (void)setHud:(MBProgressHUD *)hud {
    [self willChangeValueForKey:@"LoadingViewKey"];
    objc_setAssociatedObject(self, &LoadingViewKey, hud, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"LoadingViewKey"];
}

- (MBProgressHUD*)hud {
    return objc_getAssociatedObject(self, &LoadingViewKey);
}

- (void)beginLoading {
    
    //    for (UIView *aView in [self.blankPageContainer subviews]) {
    //        if ([aView isKindOfClass:[EaseBlankPageView class]] && !aView.hidden) {
    //            return;
    //        }
    //    }
    
    if (!self.hud) {
        MBProgressHUD *hudView = [[MBProgressHUD alloc] initWithView:self];
        self.hud = hudView;
    }
    
    [self addSubview:self.hud];
    [self.hud show:YES];
}

- (void)endLoading {
    if (self.hud) {
        [self.hud hide:YES];
    }
    [self.hud removeFromSuperview];
}

#pragma mark - EaseBlankPageView
- (void)setBlankPageView:(EaseBlankPageView *)blankPageView {
    [self willChangeValueForKey:@"BlankPageViewKey"];
    objc_setAssociatedObject(self, &BlankPageViewKey, blankPageView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"BlankPageViewKey"];
}

- (EaseBlankPageView*)blankPageView {
    return objc_getAssociatedObject(self, &BlankPageViewKey);
}

- (void)configBlankPageWithTitle:(NSString *)title hasData:(BOOL)hasData hasError:(BOOL)hasError reloadButtonBlock:(void (^)(id))block {
    if (hasData) {
        if (self.blankPageView) {
            self.blankPageView.hidden = YES;
            [self.blankPageView removeFromSuperview];
        }
    }else {
        if (!self.blankPageView) {
            self.blankPageView = [[EaseBlankPageView alloc] initWithFrame:self.bounds];
        }
        self.blankPageView.hidden = NO;
        [self.blankPageContainer addSubview:self.blankPageView];
    }
    
    [self.blankPageView configWithTitle:title hasData:hasData hasError:hasError reloadButtonBlock:block];
}

- (UIView *)blankPageContainer{
    UIView *blankPageContainer = self;
    for (UIView *aView in [self subviews]) {
        if ([aView isKindOfClass:[UITableView class]]) {
            blankPageContainer = aView;
        }
    }
    return blankPageContainer;
}

@end
