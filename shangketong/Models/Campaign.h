//
//  Campaign.h
//  shangketong
//  市场活动
//  Created by sungoin-zjp on 15-7-23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Campaign : NSObject
@property (nonatomic, copy) NSString *m_uid;
@property (nonatomic, copy) NSString *m_name;
@property (nonatomic, copy) NSString *m_focus;


+ (Campaign*)initWithDictionary:(NSDictionary*)dict;
- (Campaign*)initWithDataSource:(NSDictionary*)dict;

- (NSDictionary *) encodedCampaign;
@end
