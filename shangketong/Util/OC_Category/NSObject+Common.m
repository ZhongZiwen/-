//
//  NSObject+Common.m
//  shangketong
//
//  Created by sungoin-zbs on 15/8/29.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "NSObject+Common.h"
#import <JDStatusBarNotification.h>

@implementation NSObject (Common)

+ (BOOL)showError:(NSError *)error {
    // 如果statusBar上面正在显示信息，则不再用hud显示error
    if ([JDStatusBarNotification isVisible]) {
        NSLog(@"如果statusBar上面正在显示信息，则不再用hud显示error");
        return NO;
    }
    if (error.userInfo[@"desc"] != [NSNull null]) {
        NSString *errorStr = error.userInfo[@"desc"];
        [NSObject showHudTipStr:errorStr];
    }
//    NSString *errorStr = error.userInfo[@"desc"];
//    [NSObject showHudTipStr:errorStr];
    return YES;
}

+ (void)showHudTipStr:(NSString *)tipStr {
    if (tipStr && tipStr.length > 0) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:kKeyWindow animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabelFont = [UIFont boldSystemFontOfSize:15.0];
        hud.detailsLabelText = tipStr;
        hud.margin = 10.f;
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay:1.0];
    }
}

+ (void)showStatusBarQueryStr:(NSString *)tipStr {
    [JDStatusBarNotification showWithStatus:tipStr styleName:JDStatusBarStyleSuccess];
    [JDStatusBarNotification showActivityIndicator:YES indicatorStyle:UIActivityIndicatorViewStyleWhite];
}

+ (void)showStatusBarSuccessStr:(NSString *)tipStr {
    if ([JDStatusBarNotification isVisible]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [JDStatusBarNotification showActivityIndicator:NO indicatorStyle:UIActivityIndicatorViewStyleWhite];
            [JDStatusBarNotification showWithStatus:tipStr dismissAfter:1.5 styleName:JDStatusBarStyleSuccess];
        });
    }else{
        [JDStatusBarNotification showActivityIndicator:NO indicatorStyle:UIActivityIndicatorViewStyleWhite];
        [JDStatusBarNotification showWithStatus:tipStr dismissAfter:1.0 styleName:JDStatusBarStyleSuccess];
    }
}

+ (void)showStatusBarErrorStr:(NSString *)errorStr{
    if ([JDStatusBarNotification isVisible]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [JDStatusBarNotification showActivityIndicator:NO indicatorStyle:UIActivityIndicatorViewStyleWhite];
            [JDStatusBarNotification showWithStatus:errorStr dismissAfter:1.5 styleName:JDStatusBarStyleError];
        });
    }else{
        [JDStatusBarNotification showActivityIndicator:NO indicatorStyle:UIActivityIndicatorViewStyleWhite];
        [JDStatusBarNotification showWithStatus:errorStr dismissAfter:1.5 styleName:JDStatusBarStyleError];
    }
}

+ (void)showStatusBarError:(NSError *)error{
    NSString *errorStr = error.userInfo[@"desc"];
    [NSObject showStatusBarErrorStr:errorStr];
}

@end
