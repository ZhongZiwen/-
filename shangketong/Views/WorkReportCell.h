//
//  WorkReportCell.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/8.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WorkReportItem;

@interface WorkReportCell : UITableViewCell

+ (CGFloat)cellHeight;
- (void)configWithModel:(WorkReportItem*)item andReportType:(NSInteger)type;
@end
