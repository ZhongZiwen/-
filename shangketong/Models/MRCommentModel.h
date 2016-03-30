//
//  MRCommentModel.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/1.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRCommentModel : NSObject

@property (nonatomic, copy) NSString *user_name;
@property (nonatomic, copy) NSString *user_uid;
@property (nonatomic, copy) NSString *user_icon;
@property (nonatomic, copy) NSString *m_content;
@property (nonatomic, copy) NSString *m_id;
@property (nonatomic, copy) NSString *m_time;

+ (MRCommentModel*)initWithDictionary:(NSDictionary*)dict;
- (MRCommentModel*)initWithDictionary:(NSDictionary*)dict;
@end
