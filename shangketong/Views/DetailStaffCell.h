//
//  DetailStaffCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/11.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailStaffModel;

@interface DetailStaffCell : UITableViewCell

@property (strong, nonatomic) UIImageView *indicatorView;
@property (copy, nonatomic) void(^showBtnClickedBlock) (NSInteger);
@property (copy, nonatomic) void(^iconViewClickedBlock) (void);

+ (CGFloat)cellHeight;
- (void)configWithModel:(DetailStaffModel*)item codeStatus:(NSNumber*)status indexPath:(NSIndexPath*)path;
@end
