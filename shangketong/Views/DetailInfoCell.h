//
//  DetailInfoCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/8.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ColumnModel;

@interface DetailInfoCell : UITableViewCell

@property (copy, nonatomic) void(^headerViewTapBlock)(void);

+ (CGFloat)cellHeightWithModel:(ColumnModel*)model;
- (void)configWithModel:(ColumnModel*)model;
@end
