//
//  SaleLead.h
//  shangketong
//  销售线索
//  Created by sungoin-zjp on 15-7-23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SaleLead : NSObject

@property (nonatomic, copy) NSString *m_uid;
@property (nonatomic, copy) NSString *m_name;
@property (nonatomic, copy) NSString *m_ownerId;
@property (nonatomic, copy) NSString *m_pinyin;
@property (nonatomic, copy) NSString *m_companyName;
@property (nonatomic, assign) NSInteger m_status;
@property (nonatomic, copy) NSString *m_mobile;
@property (nonatomic, copy) NSString *m_phone;
@property (nonatomic, copy) NSString *m_post;
@property (nonatomic, copy) NSString *m_address;
@property (nonatomic, assign) NSInteger m_highSeaStatus;
@property (nonatomic, copy) NSString *m_expireTime;
@property (nonatomic, copy) NSString *m_claimTime;
@property (nonatomic, copy) NSString *m_createdAt;
@property (nonatomic, copy) NSString *m_recentActivityRecordTime;
@property (nonatomic, assign) NSInteger m_delFlg;

+ (SaleLead*)initWithDataSource:(NSDictionary*)dict;
- (SaleLead*)initWithDataSource:(NSDictionary*)dict;

@end
