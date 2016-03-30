//
//  TeamMember.h
//  shangketong
//
//  Created by sungoin-zjp on 15-9-7.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TeamMember : NSObject

@property (nonatomic, copy) NSString *m_id;
@property (nonatomic, copy) NSString *m_name;
@property (nonatomic, copy) NSString *m_icon;

+ (TeamMember*)initWithDictionary:(NSDictionary*)dict;
- (TeamMember*)initWithDictionary:(NSDictionary*)dict;

@end
