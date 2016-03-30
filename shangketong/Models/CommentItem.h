//
//  CommentItem.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/6.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommentItem : NSObject

@property (copy, nonatomic) NSString *m_content;
@property (copy, nonatomic) NSString *m_createTime;
@property (assign, nonatomic) NSInteger m_id;
@property (strong, nonatomic) NSArray *m_usersArray;

@property (copy, nonatomic) NSString *user_name;
@property (copy, nonatomic) NSString *user_icon;
@property (assign, nonatomic) NSInteger user_uid;

+ (instancetype)initWithDictionary:(NSDictionary*)dict;
- (instancetype)initWithDictionary:(NSDictionary*)dict;
@end
