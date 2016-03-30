//
//  Directory.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/31.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Directory : NSObject

@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) NSNumber *type;           // 1文件夹 2文件
@property (strong, nonatomic) NSNumber *child;          // 目录下文件数量
@property (strong, nonatomic) NSNumber *downloadAble;   // 是否可下载
@property (strong, nonatomic) NSNumber *hasFavorite;
@property (strong, nonatomic) NSNumber *resourceId;
@property (strong, nonatomic) NSNumber *size;
@property (strong, nonatomic) NSDate *createDate;
@property (strong, nonatomic) User *creator;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *url;

@property (copy, nonatomic) NSString *fileType;
@property (copy, nonatomic) NSString *fileSize;
@property (copy, nonatomic) NSString *fileIcon;

- (void)configFileTypeAndSize;
@end