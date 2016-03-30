//
//  SKT_AliCloudOSS_Model.h
//  shangketong
//
//  Created by zjp on 12/28/15.
//  Copyright (c) 2015 zjp. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SKT_AliCloudOSS_Model : NSObject

///存储目录
@property (copy, nonatomic) NSString *bucketName;
///文件唯一key
@property (copy, nonatomic) NSString *objectKey;
///本地路径
@property (copy, nonatomic) NSString *filePath;
///data
@property (copy, nonatomic) NSData *uploadData;

@end
