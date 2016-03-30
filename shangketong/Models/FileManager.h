//
//  FileManager.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/18.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFURLSessionManager.h>

@class Net_DownloadTask;

@interface FileManager : NSObject

// 下载
+ (FileManager*)sharedManager;
+ (AFURLSessionManager*)af_manager;
- (AFURLSessionManager*)af_manager;

- (NSURL*)urlForDownloadFile:(NSString*)fileName;
- (BOOL)isExistedForFileName:(NSString*)fileName;
- (BOOL)deleteFileWithName:(NSString*)fileName;

- (void)downloadFileWithOption:(NSDictionary*)paramDict urlString:(NSString*)urlStr fileName:(NSString*)fileName downloadSuccess:(void(^)(AFHTTPRequestOperation *operation, id responseObject))success downloadFailure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure progress:(void(^)(float progress))progress;
- (void)cancelDownload;
@end