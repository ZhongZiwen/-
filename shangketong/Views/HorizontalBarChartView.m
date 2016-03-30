//
//  HorizontalBarChartView.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/19.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "HorizontalBarChartView.h"
#import "UIView+Common.h"
#import "NSString+Common.h"
#import "ChartDataItem.h"
#import "StepSlider.h"
#import "PNChart.h"

#define kBarChartTag                863496
#define kBarValueLabelTag           345678
#define kHorizontalBarWidth         15      // 水平图表立柱的宽度
#define kHorizontalBarSpace         ((200 - 5 * kHorizontalBarWidth) / 5.0)    // 水平图表立柱间的宽度
#define kHorizontalBarChartHeight   200     // 水平图表的固定高度
#define kHorizontalPageControlWidth 25      // 水平图表中pagecontrol的宽度

@interface HorizontalBarChartView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) StepSlider *stepSlider;
@property (nonatomic, strong) PNBarChart *barChart;

@property (nonatomic, strong) NSMutableArray *stepLocationArray;    // 分步slider的布点坐标
@property (nonatomic, strong) NSMutableArray *stepConditionArray;   // 分步slider滑动时坐标判断条件数组

@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, strong) NSNumberFormatter *numberFormatter;

/** 根据索引获取图表立柱的name标签*/
- (NSMutableArray*)getXLabelsArray;

/** 根据索引获取前五个图表立柱的值，其余的设置为0*/
- (NSMutableArray*)getYValuesArray;

/** 根据索引获取slider的相关数组*/
- (void)getSliderSourceAtIndex:(NSInteger)page;

/** 根据索引，将bar的grade赋值为0、将valuelabel的坐标赋值为zero*/
- (void)setBarGradeAndValueLabelToZeroAtIndex:(NSInteger)page;

/** 根据索引，将bar的grade和valuelabel的frame重新赋值*/
- (void)assignBarGradeAndValueLabelFrameAtIndex:(NSInteger)page;

/** 根据相应条件获取valuelabel的frame*/
- (CGRect)getValueFrameWithBar:(PNBar*)bar andValueString:(NSString*)valueStr;
@end

@implementation HorizontalBarChartView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];

        [self addSubview:self.pageControl];
        [self addSubview:self.scrollView];
        [self addSubview:self.stepSlider];

        NSInteger count = [[self.numberFormatter numberFromString:@"1.2321312E7"] integerValue];
        NSString *countStr = [self.numberFormatter stringFromNumber:[NSNumber numberWithInteger:count]];
        NSLog(@"count = %d", count);
        NSLog(@"countStr = %@", countStr);
    }
    return self;
}

#pragma mark - Private Method
- (NSMutableArray*)getXLabelsArray {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    for (ChartDataItem *item in _dataArray) {
        [array addObject:item.m_name];
    }
    return array;
}

- (NSMutableArray*)getYValuesArray {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    int i = 0;
    for (ChartDataItem *item in _dataArray) {
        if (i < 5) {
            [array addObject:@([[self.numberFormatter numberFromString:item.m_count] integerValue])];
        }else {
            [array addObject:@0];
        }
        
        i ++;
    }
    return array;
}

- (void)getSliderSourceAtIndex:(NSInteger)page {
    [_stepLocationArray removeAllObjects];
    [_stepConditionArray removeAllObjects];
    for (int i = 5 * page; i < _barChart.bars.count; i ++) {
        PNBar *bar = _barChart.bars[i];
        if (i < 5 * page + 5) {
            [_stepLocationArray addObject:@(bar.frame.origin.x + kHorizontalBarWidth / 2.0 - kHorizontalBarChartHeight * page)];
            [_stepConditionArray addObject:@(bar.frame.origin.x + kHorizontalBarWidth - kHorizontalBarChartHeight * page)];
        }
    }
    
    _stepSlider.locationArray = _stepLocationArray;
    _stepSlider.conditionArray = _stepConditionArray;
}

- (void)setBarGradeAndValueLabelToZeroAtIndex:(NSInteger)page {
    for (int i = 5 * page; i < _barChart.bars.count; i ++) {
        PNBar *bar = _barChart.bars[i];
        UILabel *valueLabel = (UILabel*)[_scrollView viewWithTag:kBarValueLabelTag + i];
        if (i < 5 * page + 5) {
            bar.grade = 0;
            valueLabel.frame = CGRectZero;
        }
    }
}

- (void)assignBarGradeAndValueLabelFrameAtIndex:(NSInteger)page {
    for (int i = 5 * page; i < _barChart.bars.count; i ++) {
        PNBar *bar = _barChart.bars[i];
        UILabel *valueLabel = (UILabel*)[_scrollView viewWithTag:kBarValueLabelTag + i];
        if (i < 5 * page + 5) {
            NSInteger _count = [[self.numberFormatter numberFromString:((ChartDataItem*)_dataArray[i]).m_count] integerValue];
            NSString *valueStr = [self.numberFormatter stringFromNumber:[NSNumber numberWithInteger:_count]];
            CGFloat _grade = _count / (float)_barChart.yValueMax;
            if (_grade) {
                bar.grade = _grade;
            }else {
                bar.grade = 0.03;
            }
            
            valueLabel.frame = [self getValueFrameWithBar:bar andValueString:valueStr];
            CABasicAnimation *opacituAnimation = [self fadeAnimation];
            [valueLabel.layer addAnimation:opacituAnimation forKey:nil];
        }
    }
}

- (CGRect)getValueFrameWithBar:(PNBar*)bar andValueString:(NSString*)valueStr {
    
    CGRect frame;
    
    CGFloat width_valueStr = [valueStr getWidthWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(MAXFLOAT, kHorizontalBarWidth)];
    
    CGFloat origin_X;
    
    if (bar.grade == 1) {
        origin_X = 5;
    }else {
        origin_X = CGRectGetHeight(bar.bounds) - (bar.grade * CGRectGetHeight(bar.bounds) + 5 + width_valueStr);
    }
    
    frame = CGRectMake(0, origin_X, kHorizontalBarWidth, width_valueStr);
    
    return frame;
}

-(CABasicAnimation*)fadeAnimation
{
    CABasicAnimation* fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    fadeAnimation.toValue = [NSNumber numberWithFloat:1.0];
    fadeAnimation.duration = 1.5;
    
    return fadeAnimation;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    CGFloat pageWidth = CGRectGetWidth(scrollView.bounds);
    
    self.currentPage = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
}

#pragma mark - setters and getters
- (void)setDataArray:(NSArray *)dataArray {
    _dataArray = dataArray;
    
    if (!_dataArray.count)
        return;
    
    NSInteger pageCount = (_dataArray.count % 5 ? _dataArray.count / 5 + 1 : _dataArray.count / 5);
    _pageControl.numberOfPages = pageCount;
    _scrollView.contentSize = CGSizeMake(CGRectGetWidth(_scrollView.bounds) * pageCount, CGRectGetHeight(_scrollView.bounds));
    
    [_scrollView addSubview:self.barChart];
    [_barChart setWidth:CGRectGetWidth(_scrollView.bounds) * pageCount];
    _barChart.xLabels = [self getXLabelsArray];
//    _barChart.yValueMax = [((ChartDataItem*)_dataArray[0]).m_count floatValue];
    _barChart.yValues = [self getYValuesArray];
    [_barChart strokeChart];
    
    _stepLocationArray = [NSMutableArray arrayWithCapacity:5];
    _stepConditionArray = [NSMutableArray arrayWithCapacity:5];
    
    // 重新布置立柱的坐标、生成每个立柱的标签和显示立柱值的标签
    for (int i = 0; i < _barChart.bars.count; i ++) {
        PNBar *bar = _barChart.bars[i];
        
        [bar setX:kHorizontalBarSpace + (kHorizontalBarWidth + kHorizontalBarSpace) * i];
        [bar setY:CGRectGetHeight(_barChart.bounds) - CGRectGetHeight(bar.bounds)];
        
        // 初始化立柱的标签
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        nameLabel.transform = CGAffineTransformMakeRotation(-M_PI/2);
        nameLabel.frame = CGRectMake((kHorizontalBarSpace + kHorizontalBarWidth) * i, 0, kHorizontalBarSpace, CGRectGetHeight(_scrollView.bounds));
        nameLabel.backgroundColor = [UIColor whiteColor];
        nameLabel.font = [UIFont systemFontOfSize:12];
        nameLabel.text = ((ChartDataItem*)_dataArray[i]).m_name;
        [_barChart addSubview:nameLabel];

        NSInteger value = [[self.numberFormatter numberFromString:((ChartDataItem*)_dataArray[i]).m_count] integerValue];
        NSString *valueStr = [self.numberFormatter stringFromNumber:[NSNumber numberWithInteger:value]];
        
        // 初始化立柱值标签
        UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        valueLabel.transform = CGAffineTransformMakeRotation(-M_PI/2);
        valueLabel.tag = kBarValueLabelTag + i;
        valueLabel.font = [UIFont systemFontOfSize:12];
        valueLabel.textColor = [UIColor grayColor];
        valueLabel.text = valueStr;
        [bar addSubview:valueLabel];
        
        if (i < 5) {
            // 分步slider提供数据源
            [_stepLocationArray addObject:@(bar.frame.origin.x + kHorizontalBarWidth / 2.0)];
            [_stepConditionArray addObject:@(bar.frame.origin.x + kHorizontalBarWidth)];
            
            // grade等于0的时候，给一个初始值
            if (!bar.grade) {
                bar.grade = 0.03;
            }
            
            //  设置valuelabel的坐标
            valueLabel.frame = [self getValueFrameWithBar:bar andValueString:valueStr];
            CABasicAnimation *opacituAnimation = [self fadeAnimation];
            [valueLabel.layer addAnimation:opacituAnimation forKey:nil];
        }
    }

    [self getSliderSourceAtIndex:0];
}

- (void)setCurrentPage:(NSInteger)currentPage {
    if (_currentPage == currentPage)
        return;
    
    // _currentPage改变前的操作
    [self setBarGradeAndValueLabelToZeroAtIndex:_currentPage];
    
    _currentPage = currentPage;
    
    // _currentPage赋新值后的操作
    _pageControl.currentPage = _currentPage;

    [self assignBarGradeAndValueLabelFrameAtIndex:_currentPage];
    
    [self getSliderSourceAtIndex:_currentPage];
}

- (UIScrollView*)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _scrollView.transform = CGAffineTransformMakeRotation(M_PI/2);
        _scrollView.frame = CGRectMake(kHorizontalPageControlWidth, 0, CGRectGetWidth(self.bounds)-kHorizontalPageControlWidth, kHorizontalBarChartHeight);
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
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectZero];
        _pageControl.transform = CGAffineTransformMakeRotation(M_PI/2);
        _pageControl.frame = CGRectMake(0, 0, kHorizontalPageControlWidth, kHorizontalBarChartHeight);
        _pageControl.currentPage = 0;
        _pageControl.currentPageIndicatorTintColor = kTitleColor;
        _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    }
    return _pageControl;
}

- (StepSlider*)stepSlider {
    if (!_stepSlider) {
        _stepSlider = [[StepSlider alloc] initWithFrame:CGRectZero];
        _stepSlider.transform = CGAffineTransformMakeRotation(M_PI/2);
        _stepSlider.frame = CGRectMake(CGRectGetWidth(self.bounds) - 64, 0, 64, kHorizontalBarChartHeight + 15);
        _stepSlider.thumbImageString = @"dashboard_Funnel_Slider_MoveView";
        _stepSlider.sliderValueBlock = ^(NSInteger value) {
            NSLog(@"slider value = %d", value);
        };
    }
    return _stepSlider;
}

- (PNBarChart*)barChart {
    if (!_barChart) {
        _barChart = [[PNBarChart alloc] initWithFrame:CGRectMake(0, 0, 0, CGRectGetHeight(_scrollView.bounds))];
        _barChart.backgroundColor = [UIColor whiteColor];
        _barChart.barBackgroundColor = [UIColor whiteColor];
        _barChart.barWidth = kHorizontalBarWidth;
        _barChart.barRadius = 0;
        _barChart.yChartLabelWidth = 0;     // 设置y轴上标签的宽度（0为不显示）
        _barChart.xLabelSkip = 0;
        _barChart.yLabelFormatter = ^(CGFloat yValue) {
            CGFloat yValueParsed = yValue;
            NSString *labelText = [NSString stringWithFormat:@"%1.f", yValueParsed];
            return labelText;
        };
    }
    return _barChart;
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
