//
//  ActivityRecordDailyCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/9/28.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ActivityType;

@interface ActivityRecordDailyCell : UITableViewCell

@property (copy, nonatomic) void(^popBlock)(void);

+ (CGFloat)cellHeight;
- (void)configWithModel:(ActivityType*)model;
@end
