//
//  LLC_NSUserDefaults_Cache.h
//  联络中心数据缓存
//
//  Created by sungoin-zjp on 15/12/30.
//
//

#import <Foundation/Foundation.h>

@interface LLC_NSUserDefaults_Cache : NSObject

#pragma mark - 帐号
///存储当前用户帐号信息
+(void)setUserAccountInfo:(NSDictionary *)userInfo;
///获取存储的当前用户帐号信息
+(NSDictionary *)getUserAccountInfo;

///根据商客通返回登陆信息  存储联络中心账号信息
+(void)saveLLCAccountInfo:(NSDictionary *)loginInfo;

@end
