//
//  Code.h
//  shangketong
//
//  Created by sungoin-zbs on 16/1/7.
//  Copyright © 2016年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Code : NSObject

/**
 * 说明
 * 1:市场活动(1000,"删除市场活动")(1001,"转移市场活动")(1002,"变更团队成员")(1005,"能否修改资料")
 * 2:客户(2000,"删除客户")(2001,"转移客户")(2002,"变更团队成员")(2005,"能否修改资料")(2006,"退回公海池")(2007,"废弃客户")
 * 3:联系人(4000,"删除联系人")(4001,"转移联系人")(4002,"变更团队成员")(4005,"能否修改资料")
 * 4:销售机会(3000,"删除销售机会")(3001,"转移销售机会")(3002,"变更团队成员")(3005,"能否修改资料")
 */

@property (strong, nonatomic) NSNumber *code;
@property (strong, nonatomic) NSNumber *status;
@end
