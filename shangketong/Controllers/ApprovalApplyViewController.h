//
//  ApprovalApplyViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/7/31.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ApplyFlowType) {
    ApplyFlowTypeApprovalType,      // 选择申请类型
    ApplyFlowTypeApprovalFlow       // 选择流程
};

@interface ApprovalApplyViewController : UIViewController

@property (nonatomic, assign) ApplyFlowType applyType;
@property (nonatomic, assign) NSInteger approvalTypeId;     // 用于获取指定类型的流程
@property (nonatomic, copy) void(^refreshBlock)();
@end
