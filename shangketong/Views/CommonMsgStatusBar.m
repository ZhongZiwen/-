//
//  CommonMsgStatusBar.m
//  shangketong
//
//  Created by sungoin-zjp on 15-9-2.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "CommonMsgStatusBar.h"

@implementation CommonMsgStatusBar

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.windowLevel = UIWindowLevelStatusBar + 1.0f;
        self.backgroundColor = [UIColor blackColor];
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.font = [UIFont systemFontOfSize:11.0];
        _messageLabel.textColor = [UIColor whiteColor];
        [self addSubview:_messageLabel];
        self.hidden = YES;
    }
    
    return self;
}


- (void)showStatusMessage:(NSString *)message{
    self.hidden = NO;
    self.alpha = 1.0f;
   
    CGSize totalSize = self.frame.size;
    self.frame = (CGRect){ self.frame.origin, totalSize.width, 0 };

    [UIView animateWithDuration:1.0f animations:^{
         _messageLabel.text = message;
        self.frame = (CGRect){ self.frame.origin, totalSize };
    } completion:^(BOOL finished){
        _messageLabel.text = message;
        [self hide];
    }];
}
- (void)hide{
    self.alpha = 1.0f;
    [UIView animateWithDuration:1.0f animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished){
        _messageLabel.text = @"";
        self.hidden = YES;
    }];;
    
}

@end
