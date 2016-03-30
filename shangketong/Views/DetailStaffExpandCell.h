//
//  DetailStaffExpandCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/11.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailStaffModel;

@interface DetailStaffExpandCell : UITableViewCell

@property (copy, nonatomic) void(^changeBtnClickedBlock) (void);
@property (copy, nonatomic) void(^deleteBtnClickedBlock) (void);

+ (CGFloat)cellHeight;
- (void)configWithModel:(DetailStaffModel*)model;
@end
