//
//  UserSession.m
//  lianluozhongxin
//
//  Created by Vescky on 14-6-17.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import "UserSession.h"


static UserSession *defaultUserSession;

@implementation UserSession {
    
}

+ (id)shareSession {
    if (!defaultUserSession) {
        defaultUserSession = [[UserSession alloc] init];
    }
    return defaultUserSession;
}

#pragma mark - Private -- 定义储存的基本方法
- (bool)saveObject:(id)obj forKey:(NSString*)key {
    if (!obj || !key) {
        return NO;
    }
    NSUserDefaults *usd = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obj];
    [usd setObject:data forKey:key];
    [usd synchronize];
    return YES;
}

- (id)getObjectForKey:(NSString*)key {
    if (!key) {
        return nil;
    }
    NSUserDefaults *usd = [NSUserDefaults standardUserDefaults];
    NSLog(@"%@",[NSKeyedUnarchiver unarchiveObjectWithData:[usd objectForKey:key]]);
    return [NSKeyedUnarchiver unarchiveObjectWithData:[usd objectForKey:key]];
}

- (bool)removeObjectForKey:(NSString*)key {
    if (!key) {
        return NO;
    }
    NSUserDefaults *usd = [NSUserDefaults standardUserDefaults];
    [usd removeObjectForKey:key];
    [usd synchronize];
    return YES;
}

#pragma mark - Public -- 定义储存的拓展方法
- (bool)saveLoginInfo:(NSDictionary*)dict {
    return [self saveObject:dict forKey:@"login_info"];
}

- (NSDictionary*)getLoginInfo {
    return [self getObjectForKey:@"login_info"];
}

- (bool)destroyLoginInfo {
//    return [self removeObjectForKey:@"login_info"];
    NSDictionary *dict = [self getLoginInfo];
    if (!dict) {
        return NO;
    }
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:dict];
    [params setObject:@0 forKey:@"auto-login"];
    [self saveLoginInfo:params];
    return YES;
}

- (bool)saveAccountDetailInfo:(NSDictionary*)dict {
    return [self saveObject:dict forKey:@"account_detail_info"];
}

- (NSDictionary*)getAccountDetailInfo {
    return [self getObjectForKey:@"account_detail_info"];
}

- (bool)destroyAccountDetailInfo {
    return [self removeObjectForKey:@"account_detail_info"];
}

- (bool)canPlayVoiceWithoutWiFi {
    return [[self getObjectForKey:@"wifi"] boolValue];
}
- (void)setCanPlayVoiceWithoutWifi:(bool)isCan {
    [self saveObject:[NSNumber numberWithBool:isCan] forKey:@"wifi"];
}

@end
