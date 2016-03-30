//
//  VisitingTableViewCell.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/17.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ActivityItem;

@interface ActivityTableViewCell : UITableViewCell

+ (CGFloat)cellHeightWithItem:(ActivityItem*)item;
- (void)configWithItem:(ActivityItem*)item;
@end
