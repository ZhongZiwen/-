//
//  SKT_AliCloudOSS_Util.m
//  shangketong
//
//  Created by zjp on 12/28/15.
//  Copyright (c) 2015 zjp. All rights reserved.
//

#define SKT_ALICLOUD_OSS_BUCKETNAME_IMG @"sun-real-wei"
#define SKT_ALICLOUD_OSS_BUCKETNAME_VOICE @"sun-real-wei"
#define SKT_ALICLOUD_OSS_BUCKETNAME_HOSTID @"oss-cn-shanghai.aliyuncs.com"

#import "SKT_AliCloudOSS_Util.h"
#import <AliyunOSSiOS/OSSService.h>
#import <AliyunOSSiOS/OSSCompat.h>
#import <UIKit/UIKit.h>


///配置信息
NSString * const AccessKey = @"XyBWrqwtGVbk7oSw";
NSString * const SecretKey = @"uzV3cZ75ENs5lbKC4033rn5FdrzZGP";
NSString * const endPoint = @"http://oss-cn-shanghai.aliyuncs.com";
/// 上传的存储目录
NSString * const bucketName = @"sun-real-wei";


//http://www.bkjia.com/IOSjc/1075841.html

static  OSSClient * ossClient = nil;


@implementation SKT_AliCloudOSS_Util


+(OSSClient *)sharedOSSClient{
    @synchronized(self){
        if (!ossClient) {
            [self initOSSClient];
        }
    }
    return ossClient;
}


+ (void)initOSSClient {
    
    id<OSSCredentialProvider> credential = [[OSSPlainTextAKSKPairCredentialProvider alloc] initWithPlainTextAccessKey:AccessKey
                                                                                                            secretKey:SecretKey];
    
    /*
     // 自实现签名，可以用本地签名也可以远程加签
     id<OSSCredentialProvider> credential1 = [[OSSCustomSignerCredentialProvider alloc] initWithImplementedSigner:^NSString *(NSString *contentToSign, NSError *__autoreleasing *error) {
     NSString *signature = [OSSUtil calBase64Sha1WithData:contentToSign withSecret:SecretKey];
     if (signature != nil) {
     *error = nil;
     } else {
     // construct error object
     *error = [NSError errorWithDomain:@"<your error domain>" code:OSSClientErrorCodeSignFailed userInfo:nil];
     return nil;
     }
     return [NSString stringWithFormat:@"OSS %@:%@", AccessKey, signature];
     }];
     
     // Federation鉴权，建议通过访问远程业务服务器获取签名
     // 假设访问业务服务器的获取token服务时，返回的数据格式如下：
     // {"accessKeyId":"STS.iA645eTOXEqP3cg3VeHf",
     // "accessKeySecret":"rV3VQrpFQ4BsyHSAvi5NVLpPIVffDJv4LojUBZCf",
     // "expiration":"2015-11-03T09:52:59Z[;",
     // "federatedUser":"335450541522398178:alice-001",
     // "requestId":"C0E01B94-332E-4582-87F9-B857C807EE52",
     // "securityToken":"CAES7QIIARKAAZPlqaN9ILiQZPS+JDkS/GSZN45RLx4YS/p3OgaUC+oJl3XSlbJ7StKpQp1Q3KtZVCeAKAYY6HYSFOa6rU0bltFXAPyW+jvlijGKLezJs0AcIvP5a4ki6yHWovkbPYNnFSOhOmCGMmXKIkhrRSHMGYJRj8AIUvICAbDhzryeNHvUGhhTVFMuaUE2NDVlVE9YRXFQM2NnM1ZlSGYiEjMzNTQ1MDU0MTUyMjM5ODE3OCoJYWxpY2UtMDAxMOG/g7v6KToGUnNhTUQ1QloKATEaVQoFQWxsb3cSHwoMQWN0aW9uRXF1YWxzEgZBY3Rpb24aBwoFb3NzOioSKwoOUmVzb3VyY2VFcXVhbHMSCFJlc291cmNlGg8KDWFjczpvc3M6KjoqOipKEDEwNzI2MDc4NDc4NjM4ODhSAFoPQXNzdW1lZFJvbGVVc2VyYABqEjMzNTQ1MDU0MTUyMjM5ODE3OHIHeHljLTAwMQ=="}
     id<OSSCredentialProvider> credential2 = [[OSSFederationCredentialProvider alloc] initWithFederationTokenGetter:^OSSFederationToken * {
     NSURL * url = [NSURL URLWithString:@"http://localhost:8080/distribute-token.json"];
     NSURLRequest * request = [NSURLRequest requestWithURL:url];
     OSSTaskCompletionSource * tcs = [OSSTaskCompletionSource taskCompletionSource];
     NSURLSession * session = [NSURLSession sharedSession];
     NSURLSessionTask * sessionTask = [session dataTaskWithRequest:request
     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
     if (error) {
     [tcs setError:error];
     return;
     }
     [tcs setResult:data];
     }];
     [sessionTask resume];
     [tcs.task waitUntilFinished];
     if (tcs.task.error) {
     NSLog(@"get token error: %@", tcs.task.error);
     return nil;
     } else {
     NSDictionary * object = [NSJSONSerialization JSONObjectWithData:tcs.task.result
     options:kNilOptions
     error:nil];
     OSSFederationToken * token = [OSSFederationToken new];
     token.tAccessKey = [object objectForKey:@"accessKeyId"];
     token.tSecretKey = [object objectForKey:@"accessKeySecret"];
     token.tToken = [object objectForKey:@"securityToken"];
     token.expirationTimeInGMTFormat = [object objectForKey:@"expiration"];
     NSLog(@"get token: %@", token);
     return token;
     }
     }];
     */
    
    OSSClientConfiguration * conf = [OSSClientConfiguration new];
    conf.maxRetryCount = 0;
    conf.timeoutIntervalForRequest = 15;
    conf.timeoutIntervalForResource = 24 * 60 * 60;
    
    ossClient = [[OSSClient alloc] initWithEndpoint:endPoint credentialProvider:credential clientConfiguration:conf];
}

#pragma mark - 根据objectkey获取图片URL
+(NSString *)imageURLWithObjectKey:(NSString *)objectKey{
    return [NSString stringWithFormat:@"http://%@.%@/%@",SKT_ALICLOUD_OSS_BUCKETNAME_IMG,SKT_ALICLOUD_OSS_BUCKETNAME_HOSTID,objectKey];
}


#pragma mark - 直接上传data或根据文件目录上传  (同步/异步)
+ (void)uploadDataWithParams:(SKT_AliCloudOSS_Model *)alicloudModek isAsync:(BOOL)isAsync andBlock:(void (^)(BOOL, NSError *))block {
    
    OSSPutObjectRequest * put = [OSSPutObjectRequest new];
    
    put.bucketName = alicloudModek.bucketName;
    put.objectKey = alicloudModek.objectKey;
    
    if (alicloudModek.uploadData) {
        put.uploadingData = alicloudModek.uploadData;
    }else{
        ///按文件路径
        put.uploadingFileURL = [NSURL fileURLWithPath:alicloudModek.filePath];
    }
    
    // optional fields
    put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
        //        NSLog(@"%lld, %lld, %lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
    };
    
    //    put.contentType = @"";
    //    put.contentMd5 = @"";
    //    put.contentEncoding = @"";
    //    put.contentDisposition = @"";
    
    OSSTask * putTask = [[self sharedOSSClient] putObject:put];
    
    ///异步
    if (isAsync) {
        [putTask continueWithBlock:^id(OSSTask *task) {
            NSLog(@"objectKey: %@", put.objectKey);
            if (!task.error) {
                NSLog(@"upload object success!");
                block(TRUE, nil);
            } else {
                NSLog(@"upload object failed, error: %@" , task.error);
                block(FALSE, task.error);
            }
            return nil;
        }];
    }else{
        ///同步
        [putTask waitUntilFinished]; // 阻塞直到上传完成
        if (!putTask.error) {
            NSLog(@"upload object success!");
            block(TRUE, nil);
        } else {
            NSLog(@"upload object failed, error: %@" , putTask.error);
            block(FALSE, putTask.error);
        }
    }
}

#pragma mark - 根据objectkey下载文件  (同步/异步)
+ (void)downloadDataWithParams:(SKT_AliCloudOSS_Model *)alicloudModek isAsync:(BOOL)isAsync andBlock:(void (^)(id, NSError *))block{
    OSSGetObjectRequest * request = [OSSGetObjectRequest new];
    // required
    request.bucketName = alicloudModek.bucketName;
    request.objectKey = alicloudModek.objectKey;
    
    //optional
    request.downloadProgress = ^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
//        NSLog(@"%lld, %lld, %lld", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    };
    
    OSSTask * getTask = [[self sharedOSSClient] getObject:request];
    
    ///异步
    if (isAsync) {
        [getTask continueWithBlock:^id(OSSTask *task) {
            if (!task.error) {
                NSLog(@"download object success!");
                OSSGetObjectResult * getResult = task.result;
                NSLog(@"download dota length: %lu", [getResult.downloadedData length]);
                
                block(getResult,nil);
            } else {
                NSLog(@"download object failed, error: %@" ,task.error);
                block(nil,task.error);
            }
            return nil;
        }];
    }else{
        ///同步
        [getTask waitUntilFinished];
        
        if (!getTask.error) {
            OSSGetObjectResult * getResult = getTask.result;
            NSLog(@"download data length: %lu", [getResult.downloadedData length]);
            block(getResult,nil);
        } else {
            NSLog(@"download data error: %@", getTask.error);
            block(nil,getTask.error);
        }
    }
}


#pragma mark - 根据objectkey删除data
+ (void)deleteDataWithParams:(SKT_AliCloudOSS_Model *)alicloudModek andBlock:(void (^)(BOOL, NSError *))block{
    OSSDeleteObjectRequest * delete = [OSSDeleteObjectRequest new];
    delete.bucketName = alicloudModek.bucketName;
    delete.objectKey = alicloudModek.objectKey;
    
    OSSTask * deleteTask = [[self sharedOSSClient] deleteObject:delete];
    [deleteTask continueWithBlock:^id(OSSTask *task) {
        if (!task.error) {
            NSLog(@"delete success !");
            block(TRUE,nil);
        } else {
            NSLog(@"delete erorr, error: %@", task.error);
            block(FALSE,task.error);
        }
        return nil;
    }];
}


// get local file dir which is readwrite able
- (NSString *)getDocumentDirectory {
    NSString * path = NSHomeDirectory();
    NSLog(@"NSHomeDirectory:%@",path);
    NSString * userName = NSUserName();
    NSString * rootPath = NSHomeDirectoryForUser(userName);
    NSLog(@"NSHomeDirectoryForUser:%@",rootPath);
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}


@end
