//
//  PerformanceTableViewCell.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/28.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PerformanceItem;

@interface PerformanceTableViewCell : UITableViewCell

+ (CGFloat)cellHeightWithItem:(PerformanceItem*)item;
- (void)configWithItem:(PerformanceItem*)item;
@end
