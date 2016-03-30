//
//  Lead.h
//  shangketong
//
//  Created by sungoin-zbs on 15/9/22.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Lead : NSObject<NSCoding, NSCopying>

@property (strong, nonatomic) NSNumber *id;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *companyName;
@property (copy, nonatomic) NSString *position;
@property (copy, nonatomic) NSString *phone;
@property (copy, nonatomic) NSString *mobile;
@property (copy, nonatomic) NSString *email;
@property (copy, nonatomic) NSString *duty;         // 职位
@property (copy, nonatomic) NSString *ownerName;    // 所有人
@property (strong, nonatomic) NSDate *createTime;
@property (strong, nonatomic) NSDate *expireDate;

// 用于发短信给销售线索时，标记是否被选定
@property (assign, nonatomic) BOOL isSelected;

+ (NSString*)keyName;
@end