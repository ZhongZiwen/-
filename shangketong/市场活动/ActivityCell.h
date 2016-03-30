//
//  ActivityCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/14.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SWTableViewCell.h"

@class ActivityModel;

@interface ActivityCell : SWTableViewCell

@property (copy, nonatomic) void(^refreshBlock)(void);

+ (CGFloat)cellHeight;
- (void)configWithItem:(ActivityModel*)item isSwipeable:(BOOL)isSwipeable;
@end
