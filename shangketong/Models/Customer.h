//
//  Customer.h
//  shangketong
//
//  Created by sungoin-zbs on 15/9/23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XLForm.h>

@interface Customer : NSObject<XLFormOptionObject, NSCoding, NSCopying>

@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) NSNumber *focus;
@property (strong, nonatomic) NSDate *createTime;
@property (strong, nonatomic) NSDate *expireDate;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *statusDesc;
@property (copy, nonatomic) NSString *position;
@property (copy, nonatomic) NSString *phone;

// 用于添加客户时，标记是否被选定
@property (assign, nonatomic) BOOL isSelected;

+ (NSString*)keyName;
@end