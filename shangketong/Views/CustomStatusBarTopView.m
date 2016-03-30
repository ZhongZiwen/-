//
//  CustomStatusBarTopView.m
//  shangketong
//
//  Created by sungoin-zjp on 15-6-4.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "CustomStatusBarTopView.h"
#import "CommonConstant.h"

@implementation CustomStatusBarTopView

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.windowLevel = UIWindowLevelStatusBar + 1.0f;
        self.backgroundColor = [UIColor blueColor];
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        
        _messageLabel.font = [UIFont systemFontOfSize:11.0];
        _messageLabel.textColor = [UIColor whiteColor];
        [self addSubview:_messageLabel];
        self.hidden = YES;
    }
    
    return self;
}

- (void)showTopViewMessage:(NSString *)message
{
    self.hidden = NO;
    _messageLabel.text = message;
}

- (void)hide
{
    self.hidden = YES;
}


/*
 
 - (void)showStatusMessage:(NSString *)message{
 self.hidden = NO;
 self.alpha = 1.0f;
 [defaultLabel setText:@"new message" animated:NO];
 
 CGSize totalSize = self.frame.size;
 self.frame = (CGRect){ self.frame.origin, 0, totalSize.height };
 
 [UIView animateWithDuration:0.5f animations:^{
 self.frame = (CGRect){ self.frame.origin, totalSize };
 } completion:^(BOOL finished){
 defaultLabel.text = message;
 }];
 }
 - (void)hide{
 self.alpha = 1.0f;
 
 [UIView animateWithDuration:0.5f animations:^{
 self.alpha = 0.0f;
 } completion:^(BOOL finished){
 defaultLabel.text = @"";
 self.hidden = YES;
 }];;
 
 }
 
 */

@end
