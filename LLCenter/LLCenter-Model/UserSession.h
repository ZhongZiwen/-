//
//  UserSession.h
//  lianluozhongxin
//
//  Created by Vescky on 14-6-17.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserSession : NSObject {
    
}

+ (id)shareSession;

//操作登陆信息
- (bool)saveLoginInfo:(NSDictionary*)dict;
- (NSDictionary*)getLoginInfo;
- (bool)destroyLoginInfo;

//操作用户详细信息
- (bool)saveAccountDetailInfo:(NSDictionary*)dict;
- (NSDictionary*)getAccountDetailInfo;
- (bool)destroyAccountDetailInfo;

- (bool)canPlayVoiceWithoutWiFi;
- (void)setCanPlayVoiceWithoutWifi:(bool)isCan;

@end
