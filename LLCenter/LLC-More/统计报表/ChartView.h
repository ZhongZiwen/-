//
//  ChartView.h
//  lianluozhongxin
//
//  Created by Vescky on 14-6-18.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChartView : UIView {
    
}

@property float labelLengthOccupy;
@property float chartHeightOccupy;
@property float chartPercentage;
@property int chartLaidMode;
@property (nonatomic,strong) UIColor *chartColor;
@property (nonatomic,strong) NSString *labelString;

enum ChartPosition {
    ChartLaidOnCenter = 0,
    ChartLaidOnButtom,
    ChartLaidOnTop
};

- (id)initWithFrame:(CGRect)frame
    chartPercentage:(float)_percentage
         chartColor:(UIColor*)_chartColor
        labelString:(NSString*)_labelString
        labelOccupy:(float)_labelOccupy;

@end
