//
//  MeBusinessAchieveCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/7/9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ChartType) {
    ChartTypeCircle,
    ChartTypeFunnel
};

@interface MeBusinessAchieveCell : UITableViewCell

+ (CGFloat)cellHeight;
- (void)configWithSource:(NSDictionary*)sourceDict andChartType:(ChartType)chartType;
@end
