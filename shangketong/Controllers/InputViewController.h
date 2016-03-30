//
//  InputViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/8/7.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XLFormDescriptor.h>

typedef NS_ENUM(NSInteger, ValueDelegateType) {
    ValueDelegateTypeXLForm,
    ValueDelegateTypeBlock,
    ValueDelegateTypeNone
};

@interface InputViewController : UIViewController<XLFormRowDescriptorViewController, XLFormRowDescriptorPopoverViewController>

@property (nonatomic, copy) NSString *rightButtonString;
@property (nonatomic, copy) NSString *placeholderString;
@property (nonatomic, copy) NSString *textString;
@property (nonatomic, copy) void(^valueBlock)(NSDictionary *dict);
@property (nonatomic, assign) ValueDelegateType delegateType;

// 审批中 同意审批或拒绝审批
@property (nonatomic, assign) NSInteger approvalAssignable; // 是否允许自选审批人 0:允许 1:指定审批人
@property (nonatomic, assign) NSInteger approvalIsLastNode; // 是否是最后一个节点 0:是   1:不是
@property (nonatomic, assign) NSInteger approvalId;
@property (nonatomic, strong) NSArray *approvalReveiwer;
@property (nonatomic, copy) void(^refreshBlock) (void);
@end
