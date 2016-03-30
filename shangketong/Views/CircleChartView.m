//
//  CircleChartView.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "CircleChartView.h"
#import "UIView+Common.h"
#import <HUChartEntry.h>
#import <HUSemiCircleChart.h>
#import <UILabel+FlickerNumber.h>

#define kCircleChartWidth   230
#define kCircleChartHeight  160

@interface CircleChartView ()

@property (nonatomic, strong) HUSemiCircleChart *circleChart;
@property (nonatomic, strong) UILabel *minLabel;
@property (nonatomic, strong) UILabel *maxLabel;
@property (nonatomic, strong) UIView *handView;                 // 指针
@property (nonatomic, strong) UILabel *finishRate;              // 完成度
@end

@implementation CircleChartView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addSubview:self.circleChart];
        [self addSubview:self.minLabel];
        [self addSubview:self.maxLabel];
        [self addSubview:self.handView];
        [self addSubview:self.finishRate];
    }
    return self;
}

- (void)setDataDict:(NSDictionary *)dataDict {
    
    NSInteger value = 100 * [dataDict[@"actuals"] integerValue] / [dataDict[@"quota"] integerValue];

    [_finishRate dd_setNumber:[NSNumber numberWithInteger:value] format:@"%@%%" formatter:nil];
    
    [UIView animateWithDuration:1.0 animations:^{
        if (value <= 100) {
            _handView.transform = CGAffineTransformMakeRotation(M_PI*floorf((long)value/(float)100));
        }else {
            _handView.transform = CGAffineTransformMakeRotation(M_PI);
        }
    }];
}

#pragma mark - setters and getters
- (HUSemiCircleChart*)circleChart {
    if (!_circleChart) {
        _circleChart = [[HUSemiCircleChart alloc] initWithFrame:CGRectMake(0, 0, kCircleChartWidth, kCircleChartHeight)];
        [_circleChart setCenterX:CGRectGetWidth(self.bounds) / 2.0];
        
        NSMutableArray *data = [NSMutableArray arrayWithObjects:[[HUChartEntry alloc] initWithName:@"1" value:@60.0], [[HUChartEntry alloc] initWithName:@"2" value:@30.0], [[HUChartEntry alloc] initWithName:@"3" value:@20.0], nil];
        
        UIColor * color1 = [UIColor colorWithRed:(CGFloat)249/255.f green:(CGFloat)57/255.f blue:(CGFloat)66/255.f alpha:1.f];
        UIColor * color2 = [UIColor colorWithRed:(CGFloat)253/255.f green:(CGFloat)213/255.f blue:(CGFloat)75/255.f alpha:1.f];
        UIColor * color3 = [UIColor colorWithRed:(CGFloat)58/255.f green:(CGFloat)164/255.f blue:(CGFloat)102/255.f alpha:1.f];
        NSMutableArray *colors = [NSMutableArray arrayWithObjects:color1, color2, color3, nil];
        
        [_circleChart setColors:colors];
        [_circleChart setData:data];
        _circleChart.showPortionTextType = DONT_SHOW_PORTION;
    }
    return _circleChart;
}

- (UILabel*)minLabel {
    if (!_minLabel) {
        _minLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_circleChart.bounds)-15-5, 64, 15)];
        [_minLabel setCenterX:_circleChart.frame.origin.x];
        _minLabel.backgroundColor = [UIColor whiteColor];
        _minLabel.font  = [UIFont fontWithName:@"Helvetica-Bold" size:14];
        _minLabel.textAlignment = NSTextAlignmentCenter;
        _minLabel.text = @"0%";
    }
    return _minLabel;
}

- (UILabel*)maxLabel {
    if (!_maxLabel) {
        _maxLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_circleChart.bounds)-15-5, 64, 15)];
        [_maxLabel setCenterX:_circleChart.frame.origin.x + CGRectGetWidth(_circleChart.bounds)];
        _maxLabel.backgroundColor = [UIColor whiteColor];
        _maxLabel.font  = [UIFont fontWithName:@"Helvetica-Bold" size:14];
        _maxLabel.textAlignment = NSTextAlignmentCenter;
        _maxLabel.text = @"120%";
    }
    return _maxLabel;
}

- (UIView*)handView {
    if (!_handView) {
        _handView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kCircleChartWidth / 2.0, 3)];
        [_handView setCenter:CGPointMake(CGRectGetWidth(self.bounds) / 2.0, 135)];
        _handView.layer.anchorPoint = CGPointMake(1.f, 0.5f);
        _handView.backgroundColor = [UIColor blackColor];
    }
    return _handView;
}

- (UILabel*)finishRate {
    if (!_finishRate) {
        _finishRate = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 30)];
        [_finishRate setCenter:CGPointMake(CGRectGetWidth(self.bounds)/2.0, CGRectGetHeight(self.bounds) - 20)];
        _finishRate.backgroundColor = [UIColor clearColor];
        _finishRate.font = [UIFont fontWithName:@"Helvetica-Bold" size:28];
        _finishRate.textAlignment = NSTextAlignmentCenter;
        _finishRate.text = @"201,000%";
    }
    return _finishRate;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
