//
//  SKT_AliCloudOSS_Util.h
//  shangketong
//  阿里云存储公用类
//  Created by zjp on 12/28/15.
//  Copyright (c) 2015 zjp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKT_AliCloudOSS_Model.h"

@interface SKT_AliCloudOSS_Util : NSObject

#pragma mark - 根据objectkey获取图片URL
+(NSString *)imageURLWithObjectKey:(NSString *)objectKey;

#pragma mark - 直接上传data或根据文件目录上传  (同步/异步)
+ (void)uploadDataWithParams:(SKT_AliCloudOSS_Model *)alicloudModek isAsync:(BOOL)isAsync andBlock:(void (^)(BOOL, NSError *))block;

#pragma mark - 根据objectkey下载文件  (同步/异步)
+ (void)downloadDataWithParams:(SKT_AliCloudOSS_Model *)alicloudModek isAsync:(BOOL)isAsync andBlock:(void (^)(id, NSError *))block;

#pragma mark - 根据objectkey删除data
+ (void)deleteDataWithParams:(SKT_AliCloudOSS_Model *)alicloudModek andBlock:(void (^)(BOOL, NSError *))block;

@end
