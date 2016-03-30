//
//  Approval.h
//  shangketong
//
//  Created by sungoin-zbs on 15/7/31.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Approval : NSObject<NSCoding>

@property (nonatomic, assign) NSInteger m_id;       // 审批id
@property (nonatomic, assign) NSInteger m_runId;    // 获取提交给我的审批详情
@property (nonatomic, assign) NSInteger m_approveStatus;    // 审批状态
@property (nonatomic, copy) NSString *m_flowName;   // 审批标题
@property (nonatomic, copy) NSString *m_createdTime;    // 审批创建时间
@property (nonatomic, copy) NSString *m_reviewTime; //最后审批时间

@property (nonatomic, copy) NSString *m_approverName;   // 审批人
@property (nonatomic, assign) NSInteger m_approverId;     // 审批人id
@property (nonatomic, copy) NSString *m_approverIcon;   // 审批人头像
@property (nonatomic, copy) NSString *m_creatIcon; //创建人头像
@property (nonatomic, copy) NSString *m_approveNo; //审批编号


- (Approval*)initWithDictionary:(NSDictionary*)dict;
+ (Approval*)initWithDictionary:(NSDictionary*)dict;
@end
