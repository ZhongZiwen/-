//
//  ActivityRecordWeeklyCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/9/28.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivityType.h"
#import "Activity.h"

@class ActivityType;

@interface ActivityRecordWeeklyCell : UITableViewCell

+ (CGFloat)cellHeight;
- (void)configWithModel:(ActivityType*)model;
- (void)strokeChartWithModel:(ActivityType*)model;
@end
