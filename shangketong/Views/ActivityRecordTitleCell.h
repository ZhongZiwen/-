//
//  ActivityRecordTitleCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/9/28.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityRecordTitleCell : UITableViewCell

+ (CGFloat)cellHeight;
- (void)configWithType:(NSInteger)type;
- (void)configWithStartDate:(NSDate*)startDate endDate:(NSDate*)endDate;
@end
