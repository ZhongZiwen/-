//
//  AFNOManagerPost.m
//  shangketong
//
//  Created by sungoin-zjp on 15-3-4.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "AFNOManagerPost.h"
#import "Net_APIUrl.h"

@implementation AFNOManagerPost

+ (instancetype)sharedClient{
    static AFNOManagerPost *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedClient = [AFNOManagerPost manager];
        // 超时时间
        _sharedClient.requestSerializer.timeoutInterval = 20;
        
        /*
         // 设置请求参数的格式：JSON格式
         _sharedClient.requestSerializer =  [AFJSONRequestSerializer serializer];
         // 设置返回数据的解析方式
         _sharedClient.responseSerializer = [AFJSONResponseSerializer serializer];
         */
        
        //         _sharedClient.responseSerializer.acceptableContentTypes = [_sharedClient.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
        
        // 设置返回数据的解析方式
        //        _sharedClient.requestSerializer = [AFJSONRequestSerializer serializer];
        
        _sharedClient.responseSerializer = [AFJSONResponseSerializer serializer];
        _sharedClient.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
        //        _sharedClient.responseSerializer = [AFHTTPResponseSerializer serializer];
        //        _sharedClient.requestSerializer.stringEncoding =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF8);
    });
    
    return _sharedClient;
}

+ (instancetype)sharedJsonClient {
    static dispatch_once_t onceToken;
    static AFNOManagerPost *apiClient = nil;
    dispatch_once(&onceToken, ^{
        apiClient = [[AFNOManagerPost alloc] initWithBaseURL:nil];
    });
    return apiClient;
}

- (instancetype)initWithBaseURL:(nullable NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/javascript", @"text/plain", nil];
        self.securityPolicy.allowInvalidCertificates = YES;
        ((AFJSONResponseSerializer*)self.responseSerializer).removesKeysWithNullValues = YES;
        self.requestSerializer.timeoutInterval = 20;
    }
    return self;
}

- (void)requestJsonDataWithPath:(NSString *)aPath withParams:(NSDictionary *)params withMethodType:(int)NetworkMethod andBlock:(void (^)(id, NSError *))block {
    
    // log请求数据
    DebugLog(@"\n==========request==========\n%@:\n%@", aPath, params);
    aPath = [aPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    // 发起请求
    switch (NetworkMethod) {
        case Get: {
            
        }
            break;
        case Post: {
            [self POST:aPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                DebugLog(@"\n%@==========success response==========:\n%@", aPath, responseObject);
                
                // 发送验证码
                if ([aPath isEqualToString:[NSString stringWithFormat:@"%@%@", kNetPath_Web_Server_Base, kNetPath_SendCaptcha]]) {
                    block(responseObject, nil);
                    return;
                }
                
                // 验证账号密码
                if ([aPath isEqualToString:[NSString stringWithFormat:@"%@%@", kNetPath_Web_Server_Base, kNetPath_CheckAccountPassword]]) {
                    block(responseObject, nil);
                    return;
                }
                
                id error = [self handleResponse:responseObject];
                if (error) {
                    [NSObject showError:error];
                    block(nil, error);
                }else {
                    block(responseObject, nil);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                DebugLog(@"\n%@==========failure response==========:\n%@", aPath, error);
                block(nil, error);
            }];
        }
            break;
        case Put: {
            
        }
            break;
        case Delete: {
            
        }
        default:
            break;
    }
}

- (void)uploadImage:(UIImage *)image path:(NSString *)path params:(id)params name:(NSString *)name successBlock:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failureBlock:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure progressBlock:(void (^)(CGFloat progressValue))progress {
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    if ((float)data.length / 1024 > 1000) {
        data = UIImageJPEGRepresentation(image, 1024*1000.0/(float)data.length);
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
    DebugLog(@"\nuploadImageSize\n%@ : %.0f", fileName, (float)data.length/1024);
    
    AFHTTPRequestOperation *operation = [self POST:path parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:name fileName:fileName mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        DebugLog(@"success: %@ ***** %@", operation.responseString, responseObject);
        id error = [self handleResponse:responseObject];
        if (error && failure) {
            failure(operation, error);
        }else {
            success(operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DebugLog(@"error: %@ ****** %@", operation.responseString, error);
        if (failure) {
            failure(operation, error);
        }
    }];
    
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        CGFloat progressValue = (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
        if (progress) {
            progress(progressValue);
        }
    }];
    [operation start];
}

- (id)handleResponse:(id)responseJSON {
    NSError *error = nil;
    // status为1时，表示有错  9请求超时
    NSNumber *resultCode = [responseJSON valueForKeyPath:@"status"];
    if (resultCode.intValue) {
        error = [NSError errorWithDomain:kNetPath_Web_Server_Base code:resultCode.intValue userInfo:responseJSON];
        
    }
    return error;
}
@end
