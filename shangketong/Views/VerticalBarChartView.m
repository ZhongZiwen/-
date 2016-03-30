//
//  VerticalBarChartView.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/19.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "VerticalBarChartView.h"
#import "UIView+Common.h"
#import "NSString+Common.h"
#import "StepSlider.h"
#import "PNChart.h"

#define kBarWidth   30

@interface VerticalBarChartView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) StepSlider *stepSlider;

@property (nonatomic, strong) NSMutableArray *stepLocationArray;    // 分步slider的布点坐标
@property (nonatomic, strong) NSMutableArray *stepConditionArray;   // 分步slider滑动时坐标判断条件数组

@property (nonatomic, strong) NSNumberFormatter *numberFormatter;

- (void)getSliderSourceAtIndex:(NSInteger)page;
@end

@implementation VerticalBarChartView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.stepSlider];
        [self addSubview:self.scrollView];
    }
    return self;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    CGFloat pageWidth = CGRectGetWidth(scrollView.bounds);
    
//    self.currentPage = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
}

#pragma mark - setters and getters
- (void)setDataArray:(NSArray *)dataArray {
    _dataArray = dataArray;
    
    if (!_dataArray.count)
        return;
    
    _stepLocationArray = [NSMutableArray arrayWithCapacity:dataArray.count];
    _stepConditionArray = [NSMutableArray arrayWithCapacity:dataArray.count];
    
    for (int i = 0; i < dataArray.count; i ++) {
        NSDictionary *dict = dataArray[i];
        
        PNBar *bar = [[PNBar alloc] initWithFrame:CGRectMake(20 + (kBarWidth + 20) * i, 10, kBarWidth, CGRectGetHeight(_scrollView.bounds) - 30)];
        bar.backgroundColor = PNLightGrey;
        bar.barRadius = 0;
        float grade;
        if ([dict[@"quota"] floatValue]) {
            grade = (float)[dict[@"actuals"] floatValue] / (float)[dict[@"quota"] floatValue];
        }else {
            grade = 0;
        }
        
        bar.grade = (grade ? grade : 0.03);
        [_scrollView addSubview:bar];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(bar.frame.origin.x - 10, bar.frame.origin.y + CGRectGetHeight(bar.bounds), kBarWidth + 20, 20)];
        titleLabel.font = [UIFont systemFontOfSize:11];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.text = dict[@"name"];
        [_scrollView addSubview:titleLabel];
        
        // 分步slider提供数据源
        [_stepLocationArray addObject:@(bar.frame.origin.x + kBarWidth / 2.0)];
        [_stepConditionArray addObject:@(bar.frame.origin.x + kBarWidth)];
    }
    
    _stepSlider.locationArray = _stepLocationArray;
    _stepSlider.conditionArray = _stepConditionArray;
}

- (UIScrollView*)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(30, 0, CGRectGetWidth(self.bounds) - 30 * 2, CGRectGetHeight(self.bounds) - 50)];
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (UIPageControl*)pageControl {
    if (!_pageControl) {
        
    }
    return _pageControl;
}

- (StepSlider*)stepSlider {
    if (!_stepSlider) {
        _stepSlider = [[StepSlider alloc] initWithFrame:CGRectMake(30, CGRectGetHeight(self.bounds) - 64, CGRectGetWidth(self.bounds) - 30 * 2, 64)];
        _stepSlider.thumbImageString = @"dashboard_Performance_Slider_MoveView";
        _stepSlider.sliderValueBlock = ^(NSInteger value) {
            NSLog(@"slider value = %d", value);
        };
    }
    return _stepSlider;
}

- (NSNumberFormatter*)numberFormatter {
    if (!_numberFormatter) {
        _numberFormatter = [[NSNumberFormatter alloc] init];
        _numberFormatter.numberStyle = kCFNumberFormatterDecimalStyle;
    }
    return _numberFormatter;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
