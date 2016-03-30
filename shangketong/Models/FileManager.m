//
//  FileManager.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/18.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "FileManager.h"
#import "Directory.h"

@interface FileManager ()

@end

@implementation FileManager

+ (FileManager*)sharedManager {
    static dispatch_once_t onceToken;
    static FileManager *_sharedManager = nil;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[FileManager alloc] init];
        [_sharedManager folderForDownload];
    });
    return _sharedManager;
}

+ (AFURLSessionManager*)af_manager {
    static dispatch_once_t af_onceToken;
    static AFURLSessionManager *_af_manager = nil;
    dispatch_once(&af_onceToken, ^{
        _af_manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    });
    return _af_manager;
}

- (AFURLSessionManager*)af_manager {
    return [FileManager af_manager];
}

- (NSURL*)urlForDownloadFile:(NSString *)fileName {
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [[self class] downloadPath], fileName];
    return [NSURL fileURLWithPath:filePath];
}

- (BOOL)isExistedForFileName:(NSString *)fileName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", [[self class] downloadPath], fileName]];
}

- (BOOL)deleteFileWithName:(NSString *)fileName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [[self class] downloadPath], fileName];
    
    if ([self isExistedForFileName:fileName]) {
        NSError *fileError;
        [fileManager removeItemAtPath:filePath error:&fileError];
        if (fileError) {
            [NSObject showError:fileError];
            return NO;
        }
        else {
            return YES;
        }
    }
    return NO;
}

+ (NSString*)downloadPath {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES) firstObject];
    NSString *downloadPath = [documentPath stringByAppendingPathComponent:@"SKT_Download"];
    return downloadPath;
}

+ (BOOL)createFolder:(NSString *)path{
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    BOOL isCreated = NO;
    if (!(isDir == YES && existed == YES)){
        isCreated = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }else{
        isCreated = YES;
    }
    return isCreated;
}

- (void)folderForDownload {
    if (![[self class] createFolder:[[self class] downloadPath]]) {
        kTipAlert(@"创建文件夹失败，无法继续下载！");
    }
}

- (void)downloadFileWithOption:(NSDictionary *)paramDict urlString:(NSString *)urlStr fileName:(NSString *)fileName downloadSuccess:(void (^)(AFHTTPRequestOperation *, id))success downloadFailure:(void (^)(AFHTTPRequestOperation *, NSError *))failure progress:(void (^)(float))progress {

//    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
//    
//    NSURL *URL = [NSURL URLWithString:urlStr];
//    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
//    
//    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
//        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
//        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
//    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
//        NSLog(@"File downloaded to: %@", filePath);
//    }];
//    
//    [manager setDownloadTaskDidWriteDataBlock:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
//        NSLog(@"totalBytesExpectedToRead = %lld, totalBytesRead = %lld", totalBytesExpectedToWrite, totalBytesWritten);
//    }];
//    
//    [downloadTask resume];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setOutputStream:[NSOutputStream outputStreamToFileAtPath:[NSString stringWithFormat:@"%@/%@", [[self class] downloadPath], fileName] append:NO]];
    
    @weakify(operation);
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        
        @strongify(operation);
        
        NSLog(@"Content-Length = %@", operation.response.allHeaderFields[@"Content-Length"]);
        
        NSLog(@"totalBytesExpectedToRead = %lld, totalBytesRead = %lld", totalBytesExpectedToRead, totalBytesRead);
        
//        float p;
//        
//        if (totalBytesExpectedToRead > 0 && totalBytesRead <= totalBytesExpectedToRead) {
//            p = (float)totalBytesRead / totalBytesExpectedToRead;
//        }
//        else {
//            p = (totalBytesRead % 1000000l) / 1000000.0f;
//        }
//        
//        progress(p);
        
        float p = (float)totalBytesRead / totalBytesExpectedToRead;
        progress(p);
    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"status = %d file = %@", operation.response.statusCode, operation.response.allHeaderFields);
        
        NSLog(@"file = %@", [NSString stringWithFormat:@"%@/%@", [[self class] downloadPath], fileName]);
        success(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation, error);
    }];
    
    [operation start];
    
//    "Access-Control-Allow-Origin" = "http://im.sunke.com";
//    Connection = "Keep-Alive";
//    "Content-Disposition" = "attachment;filename=177d1f763ef145ca90114964e0c6adbe.jpg";
//    "Content-Encoding" = gzip;
//    "Content-Length" = 29337;
//    "Content-Type" = "application/octet-stream;charset=utf-8";
//    Date = "Fri, 19 Feb 2016 02:35:58 GMT";
//    "Keep-Alive" = "timeout=30, max=400";
//    Vary = "Accept-Encoding";
    
//    "Content-Disposition" = "attachment;filename=76b8b8cb196f43559df3f965f1980c6d.mp3";
//    "Content-Length" = 4180006;
//    "Content-Type" = "application/octet-stream;charset=utf-8";
//    Date = "Fri, 19 Feb 2016 02:40:45 GMT";
//    Server = "Apache-Coyote/1.1";
}

- (void)cancelDownload {
    
}
@end

