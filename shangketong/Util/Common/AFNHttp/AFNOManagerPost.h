//
//  AFNOManagerPost.h
//  shangketong
//
//  Created by sungoin-zjp on 15-3-4.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"

typedef enum {
    Get = 0,
    Post,
    Put,
    Delete
}NetworkMethod;

@interface AFNOManagerPost : AFHTTPRequestOperationManager
+ (instancetype)sharedClient;
+ (instancetype)sharedJsonClient;

- (void)requestJsonDataWithPath:(NSString*)aPath withParams:(NSDictionary*)params withMethodType:(int)NetworkMethod andBlock:(void(^)(id data, NSError *error))block;
- (void)uploadImage:(UIImage *)image path:(NSString *)path params:(id)params name:(NSString *)name successBlock:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failureBlock:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure progressBlock:(void (^)(CGFloat progressValue))progress;
- (void)uploadVoice:(NSString*)file path:(NSString*)path params:(NSDictionary*)params block:(void(^)(id data, NSError *error))block;
@end
