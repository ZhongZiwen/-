//
//  LocalCacheUtil.h
//  本地内存管理
//
//  Created by sungoin-zjp on 16/3/8.
//
//

#import <Foundation/Foundation.h>

@interface LocalCacheUtil : NSObject

///退出登录完成 数据处理
+(void)clearCacheBylogoutComplete:(NSInteger)logoutStatus;

@end
