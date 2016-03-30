//
//  Contact.h
//  shangketong
//
//  Created by sungoin-zbs on 15/9/23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Contact : NSObject<NSCoding, NSCopying>

@property (strong, nonatomic) NSNumber *id;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *job;
@property (copy, nonatomic) NSString *companyName;
@property (copy, nonatomic) NSString *position;
@property (copy, nonatomic) NSString *email;
@property (copy, nonatomic) NSString *mobile;
@property (copy, nonatomic) NSString *phone;
@property (strong, nonatomic) NSNumber *isTouchLinkMan;     // 主联系人

@property (assign, nonatomic) BOOL isSelected;

+ (NSString*)keyName;
@end
