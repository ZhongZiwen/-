//
//  AFNOManager.m
//  shangketong
//
//  Created by sungoin-zjp on 15-2-10.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "AFNOManager.h"
@implementation AFNOManager


+ (instancetype)sharedGetClient {
    static AFNOManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        _sharedClient = [AFNOManager manager];
        
        
        // 设置请求参数的格式：JSON格式
        _sharedClient.requestSerializer =  [AFJSONRequestSerializer serializer];
        // 设置返回数据的解析方式
        _sharedClient.responseSerializer = [AFJSONResponseSerializer serializer];
        // 超时时间
        _sharedClient.requestSerializer.timeoutInterval = 10;
        //  NSNull的值，都变成nil
        
    });
    
    return _sharedClient;
}

+ (instancetype)sharedPostClient
{
    static AFNOManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedClient = [AFNOManager manager];
        // 超时时间
        _sharedClient.requestSerializer.timeoutInterval = 10;
        
    });
    
    return _sharedClient;
}

@end
