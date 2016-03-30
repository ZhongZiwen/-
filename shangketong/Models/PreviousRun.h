//
//  PreviousRun.h
//  shangketong
//
//  Created by sungoin-zbs on 15/11/6.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PreviousRun : NSObject

@property (strong, nonatomic) NSNumber *status;
@property (strong, nonatomic) NSDate *approveTime;      // 0我拒绝了此申请 1我同意了此申请
@end
