//
//  LineChartView.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/7/4.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LineChartView : UIView

- (void)configWithDataSource:(NSArray*)sourceArray;

/**
 * Draws the chart in an animated fashion.
 */
- (void)strokeChart;
@end
