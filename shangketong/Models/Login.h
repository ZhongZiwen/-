//
//  Login.h
//  PhoneMeeting
//
//  Created by 钟必胜 on 15/4/14.
//  Copyright (c) 2015年 songoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Login : NSObject

+ (BOOL) isFirstLaunch;
+ (BOOL) isLogin;
+ (void) doLogin:(NSDictionary *)loginData;
+ (void) doLogout;

@end
