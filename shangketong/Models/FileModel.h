//
//  FileModel.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileModel : NSObject

@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) NSNumber *size;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *url;
@property (copy, nonatomic) NSString *minUrl;
@end
