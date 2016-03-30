//
//  CommonMsgStatusBar.h
//  shangketong
//  在状态栏提示请求结果
//  Created by sungoin-zjp on 15-9-2.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommonMsgStatusBar : UIWindow

@property (nonatomic, strong) UILabel *messageLabel;
- (void)showStatusMessage:(NSString *)message;
- (void)hide;
@end
