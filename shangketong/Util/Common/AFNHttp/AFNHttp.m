//
//  AFNHttp.m
//  shangketong
//
//  Created by sungoin-zjp on 15-1-19.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//



#import "AFNHttp.h"
#import "AFNetworking.h"
#import "CommonConstant.h"
#import "GBMoudle.h"

#import "AFNOManagerGet.h"
#import "AFNOManagerPost.h"

@implementation AFNHttp


+(void)get:(NSString *)url params:(NSDictionary *)params success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    //3.发送Get请求
    NSLog(@"get params:%@",params);
    [[AFNOManagerGet sharedClient] GET:url parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary*responseObj) {
        if (success) {
            success(responseObj);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

+(void)post:(NSString *)url params:(NSDictionary *)params success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSLog(@"url:%@",url);
    //2.发送Post请求
    NSLog(@"post params:%@",params);
    
    [[AFNOManagerPost sharedClient] POST:url parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary*responseObj) {
        if (success) {
            success(responseObj);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            NSLog(@"failureoperation:%@",operation.responseString);
            failure(error);
        }
    }];
}

// 取消所有请求
+(void)cancelAllRequest
{
    [[AFNOManagerPost sharedClient].operationQueue cancelAllOperations];
    [[AFNOManagerGet sharedClient].operationQueue cancelAllOperations];
}


// 同步get/post请求
+(id)doSynType:(NSString *)method WithUrl:(NSString *)url params:(NSDictionary *)params{

    NSString *serUrl = url;
    
    NSLog(@"doSynType serUrl:%@",serUrl);
    NSLog(@"doSynType params:%@",params);
    
    if ([method isEqualToString:@"GET"]) {
        AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
        
        NSMutableURLRequest *request = [requestSerializer requestWithMethod:method URLString:serUrl parameters:params error:nil];
        
        AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        AFHTTPResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
        requestSerializer.timeoutInterval = 20;
        [requestOperation setResponseSerializer:responseSerializer];
        
        [requestOperation start];
        [requestOperation waitUntilFinished];
        
        NSDictionary *responseData = [requestOperation responseObject] ;
        
        return responseData;
    }else
    {

        NSMutableURLRequest *request = [[AFNOManagerPost sharedClient].requestSerializer requestWithMethod:method URLString:serUrl parameters:params error:nil];
        
        AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        
        AFHTTPResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
        request.timeoutInterval = 10;
        [requestOperation setResponseSerializer:responseSerializer];
        
        [requestOperation start];
        [requestOperation waitUntilFinished];
        
        NSDictionary *responseData = [requestOperation responseObject] ;
        
        return responseData;
    }
}


@end

