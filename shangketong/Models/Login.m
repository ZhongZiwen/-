//
//  Login.m
//  PhoneMeeting
//
//  Created by 钟必胜 on 15/4/14.
//  Copyright (c) 2015年 songoin. All rights reserved.
//

#import "Login.h"

@implementation Login

+ (BOOL) isFirstLaunch
{
    NSNumber *launchStatus = [[NSUserDefaults standardUserDefaults] objectForKey:kFirstLaunchStatus];
    if (!launchStatus.boolValue) {  // 表示初次使用app
        return YES;
    }else{
        return NO;
    }
}

+ (BOOL) isLogin
{
    /*
     NSNumber *loginStatus = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginStatus];
     if (loginStatus.boolValue && [Login curLoginUser]) {
     return YES;
     }else{
     return NO;
     }
     */
    NSNumber *loginStatus = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginStatus];
    if (loginStatus.boolValue) {
        return YES;
    }else{
        return NO;
    }
}

+ (void) doLogin:(NSDictionary *)loginData
{
    
}

+ (void) doLogout
{
    
}

@end
