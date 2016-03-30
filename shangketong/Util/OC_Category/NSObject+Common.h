//
//  NSObject+Common.h
//  shangketong
//
//  Created by sungoin-zbs on 15/8/29.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Common)

+ (BOOL)showError:(NSError*)error;
+ (void)showHudTipStr:(NSString*)tipStr;
+ (void)showStatusBarQueryStr:(NSString*)tipStr;
+ (void)showStatusBarSuccessStr:(NSString*)tipStr;
+ (void)showStatusBarErrorStr:(NSString*)errorStr;
+ (void)showStatusBarError:(NSError*)error;
@end
