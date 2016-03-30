//
//  DetailInfoSectionCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/8.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ColumnModel;

@interface DetailInfoSectionCell : UITableViewCell

+ (CGFloat)cellHeight;
- (void)configWithModel:(ColumnModel*)model;
@end
