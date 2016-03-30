//
//  ApprovalStateCell.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/31.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ProcessType) {
    ProcessTypeApply,       // 申请
    ProcessTypeApproval     // 审批
};

@interface ApprovalStateCell : UITableViewCell

+ (CGFloat)cellHeight;
- (void)configWithProcessType:(ProcessType)type andDictionary:(NSDictionary*)dict andLastObjec:(BOOL)isLast;
@end
