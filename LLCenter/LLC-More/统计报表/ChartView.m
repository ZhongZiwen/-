//
//  ChartView.m
//  lianluozhongxin
//
//  Created by Vescky on 14-6-18.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import "ChartView.h"

@implementation ChartView

@synthesize labelLengthOccupy,labelString;
@synthesize chartHeightOccupy,chartLaidMode,chartColor,chartPercentage;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
    chartPercentage:(float)_percentage
         chartColor:(UIColor*)_chartColor
        labelString:(NSString*)_labelString
        labelOccupy:(float)_labelOccupy {
    self = [super initWithFrame:frame];
    if (self) {
        if (!_chartColor) {
            _chartColor = [UIColor blackColor];
        }
        if (!_labelOccupy) {
            _labelOccupy = 0.3;
        }
        if (!chartHeightOccupy) {
            chartHeightOccupy = 0.7;
        }
        
        labelLengthOccupy = _labelOccupy;
        labelString = _labelString;
        chartPercentage = _percentage;
        chartColor = _chartColor;
        
        self.clipsToBounds = YES;
    }
    
    [self refreshView];
    
    return self;
}

- (void)refreshView {
    float labelMargin = 5.0f;
    
    float percentageViewY = 0.f;
    switch (chartLaidMode) {
        case 0://center
            percentageViewY = self.frame.size.height * ( 1 - chartHeightOccupy) / 2.0;
            break;
        case 1://buttom
            percentageViewY = self.frame.size.height * ( 1 - chartHeightOccupy);
            break;
        case 2://top,不用改
            
            break;
            
        default:
            break;
    }
    
    //创建百分比view
    UIView *percentageView = [[UIView alloc] init];
    percentageView.backgroundColor = chartColor;
    CGRect pRect = CGRectMake(0.f, percentageViewY,
                             self.frame.size.width * (1 - labelLengthOccupy) * chartPercentage,
                             self.frame.size.height * chartHeightOccupy);
    percentageView.frame = pRect;
    [self addSubview:percentageView];
    
    //创建备注label
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(percentageView.frame.origin.x + percentageView.frame.size.width + labelMargin,
                             0.f,
                             self.frame.size.width * labelLengthOccupy,
                             self.frame.size.height);
    label.text = labelString;
    label.font = [UIFont systemFontOfSize:12.0];
    label.textColor = GetColorWithRGB(61, 67, 69);
    [self addSubview:label];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
