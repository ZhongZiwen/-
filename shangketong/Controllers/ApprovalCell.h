//
//  ApprovalCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/7/31.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Approval;

@interface ApprovalCell : UITableViewCell

+ (CGFloat)cellHeight;
- (void)configWithModel:(Approval*)approval andApprovalType:(NSInteger)approvalType;
@end
