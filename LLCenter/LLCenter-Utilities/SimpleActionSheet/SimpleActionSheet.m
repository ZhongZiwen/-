//
//  SimpleActionSheet.m
//  lianluozhongxin
//
//  Created by Vescky on 14-7-7.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import "SimpleActionSheet.h"
#import <QuartzCore/QuartzCore.h>
#import "LLCenterUtility.h"
#define Gap_To_Bounce 20.0f

@implementation SimpleActionSheet

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        alertDescription = @"温馨提示";
        buttonsTitle = [[NSArray alloc] initWithObjects:@"确定",@"取消", nil];
    }
    return self;
}

- (void)refreshView {
    float labelHeight = getTextHeightForLabel(alertDescription, DEVICE_BOUNDS_WIDTH - 2 * Gap_To_Bounce, [UIFont systemFontOfSize:13.0]);
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(Gap_To_Bounce, Gap_To_Bounce, DEVICE_BOUNDS_WIDTH - 2 * Gap_To_Bounce, labelHeight)];
    label.text = alertDescription;
    label.textColor = GetColorWithRGB(100, 100, 100);
    label.textAlignment = 1;
    label.font = [UIFont systemFontOfSize:13.0];
    label.backgroundColor = [UIColor clearColor];
    [self addSubview:label];
    
    for (int i = 0; i < [buttonsTitle count]; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:
                         CGRectMake(Gap_To_Bounce,
                                    label.frame.origin.y + label.frame.size.height + Gap_To_Bounce * (i + 1) + 40.0 * i,
                                    DEVICE_BOUNDS_WIDTH - 2 * Gap_To_Bounce,
                                    40.0f)];
        
        if (i == 0) {
            btn.backgroundColor = GetColorWithRGB(230, 76, 77);
        }
        else {
            btn.backgroundColor = GetColorWithRGB(123, 129, 138);
        }
        
        btn.tintColor = [UIColor whiteColor];
        [btn setTitle:[buttonsTitle objectAtIndex:i] forState:UIControlStateNormal];
        btn.layer.cornerRadius = 5.0f;
        btn.tag = i;
        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:btn];
    }
    
    self.backgroundColor = GetColorWithRGB(237.0f, 237.0f, 237.0f);
    
    CGRect sRect = self.frame;
    sRect.size.height = labelHeight + [buttonsTitle count] * 40.0f + ([buttonsTitle count] + 2) * Gap_To_Bounce;
    self.frame = sRect;
}


- (void)setButtonsTitle:(NSArray*)arr {
    buttonsTitle = arr;
    [self refreshView];
}

- (void)setAlertDescription:(NSString*)str {
    alertDescription = str;
    [self refreshView];
}

- (void)showOnWindow:(UIWindow*)w {
    maskView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    maskView.backgroundColor = [UIColor blackColor];
    maskView.alpha = 0.0;
    CGRect sRect = self.frame;
    sRect.origin.x = 0;
    sRect.origin.y = maskView.frame.size.height;
    sRect.size.width = maskView.frame.size.width;
    self.frame = sRect;
    
    [w addSubview:maskView];
    [w addSubview:self];
    
    [UIView animateWithDuration:0.1 animations:^{
        maskView.alpha = 0.8;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect sRect = self.frame;
            sRect.origin.y = maskView.frame.size.height - sRect.size.height;
            self.frame = sRect;
        }];
    }];
    
}

- (IBAction)btnAction:(id)sender {
    UIButton *btn = (UIButton*)sender;
    if ([delegate respondsToSelector:@selector(buttonDidClickedAtIndex:)]) {
        [delegate buttonDidClickedAtIndex:btn.tag];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect sRect = self.frame;
        sRect.origin.y = maskView.frame.size.height;
        self.frame = sRect;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            maskView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [maskView removeFromSuperview];
            [self removeFromSuperview];
        }];
    }];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
