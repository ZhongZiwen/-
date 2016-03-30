//
//  BusinessFrom.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/30.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BusinessFrom : NSObject

@property (strong, nonatomic) NSNumber *id;         // 关联业务id
@property (copy, nonatomic) NSString *name;         // 关联业务名称
@property (strong, nonatomic) NSNumber *sourceId;   // 关联业务类型id
@property (copy, nonatomic) NSString *sourceName;   // 关联业务类型名称
@end