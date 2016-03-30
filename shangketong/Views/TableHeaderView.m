//
//  TableHeaderView.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/19.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "TableHeaderView.h"
#import "UIView+Common.h"
#import "UIColor+expanded.h"
#import "NSString+Common.h"
#import <UILabel+FlickerNumber.h>
#import <UIImageView+WebCache.h>
#import "HorizontalBarChartView.h"
#import "VerticalBarChartView.h"
#import "CircleChartView.h"
#import "FunnelView.h"
#import "OpportunityView.h"
#import "OpportunityChartItem.h"

#import "ChartDataItem.h"

#define kViewHeightType1001         300
#define kViewHeightType1002         300
#define kViewHeightType1003         300
#define kViewHeightType1004         340
#define kViewHeightType1005         300
#define kViewHeightType1006
#define kViewHeightType1007
#define kViewHeightType1008
#define kViewHeightType1009

#define kHeaderHeight               50      // 标题栏的高度
#define kCustomViewHeight           300     // 显示barChart视图的高度

@interface TableHeaderView ()

@property (nonatomic, strong) UIImageView *headerView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIButton *infoButton;

@property (nonatomic, strong) UIImageView *periodImageView;
@property (nonatomic, strong) UILabel *periodLabel;

@property (nonatomic, strong) NSNumberFormatter *numberFormatter;

@property (nonatomic, strong) HorizontalBarChartView *horizontalBarChart;   // 水平图表
@property (nonatomic, strong) VerticalBarChartView *verticalBarChart;       // 竖直图表

/** 近期重点商机 type = 1002*/
@property (nonatomic, strong) UILabel *opportunitySourceLabel;
@property (nonatomic, strong) OpportunityView *opportunityChart;            // 散点图表

/** 销售业绩pk type = 1003*/
@property (nonatomic, strong) UILabel *performanceOne;
@property (nonatomic, strong) UILabel *performanceTwo;
@property (nonatomic, strong) NSArray *performanceData;

/** 销售目标完成情况 type = 1001*/
@property (nonatomic, strong) UILabel *businessFinish;
@property (nonatomic, strong) CircleChartView *circleChart;
@property (nonatomic, strong) UIView *handView;                             // 指针
@property (nonatomic, strong) UILabel *finishRate;                          // 完成度

/** 漏斗 type = 1004*/
@property (nonatomic, strong) UILabel *funnelTotal;                         // 漏斗_总金额
@property (nonatomic, strong) UILabel *funnelPart;                          // 漏斗_部分
@property (nonatomic, strong) FunnelView *funnelView;


@end

@implementation TableHeaderView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

#pragma mark - event response
- (void)infoButtonPress {
    if (self.infoButtonBlock) {
        self.infoButtonBlock();
    }
}

#pragma mark - Private Method
- (NSMutableAttributedString*)getStringWithTitleOne:(NSString*)titleOne andValueOne:(NSString*)valueOne andTitleTwo:(NSString*)titleTwo andValueTwo:(NSString*)valueTwo {
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@   %@ %@", titleOne, valueOne, titleTwo, valueTwo]];
    [attriString addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14],
                                 NSForegroundColorAttributeName : [UIColor grayColor]} range:NSMakeRange(0, titleOne.length)];
    [attriString addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14],
                                 NSForegroundColorAttributeName : [UIColor colorWithHexString:@"0x3bbd79"]} range:NSMakeRange(titleOne.length+1, valueOne.length)];
    
    [attriString addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14],
                                 NSForegroundColorAttributeName : [UIColor grayColor]} range:NSMakeRange(titleOne.length + valueOne.length + 4, titleTwo.length)];
    
    [attriString addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14],
                                 NSForegroundColorAttributeName : [UIColor colorWithHexString:@"0x3bbd79"]} range:NSMakeRange(titleOne.length + valueOne.length + 4 + titleTwo.length + 1, valueTwo.length)];
    
    return attriString;
}

- (NSMutableAttributedString*)getStringWithTitle:(NSString *)title andValue:(NSString *)value{
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", title, value]];
    [attriString addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14],
                                 NSForegroundColorAttributeName : [UIColor grayColor]}
                         range:NSMakeRange(0, title.length)];
    
    [attriString addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14],
                                 NSForegroundColorAttributeName : [UIColor colorWithHexString:@"0x3bbd79"]}
                         range:NSMakeRange(title.length+1, value.length)];
    return  attriString;
}

#pragma mark - setters and getters
- (void)setChartType:(NSInteger)chartType {
    
    _chartType = chartType;
    
    if (_chartType == 1001) {
        [self setHeight:kViewHeightType1001];
        
        [self addSubview:self.headerView];
        
        [self addSubview:self.titleLabel];
        
        [self addSubview:self.infoButton];
        [_infoButton setX:CGRectGetWidth(self.bounds) - CGRectGetWidth(_infoButton.bounds)];
        [_infoButton setHeight:kHeaderHeight];
        [_titleLabel setWidth:CGRectGetWidth(self.bounds) - kHeaderHeight - CGRectGetWidth(_infoButton.bounds)];
        
        [self addSubview:self.lineView];
        
        [self addSubview:self.periodImageView];
        [_periodImageView setX:10];
        [_periodImageView setY:kHeaderHeight + 10];
        
        [self addSubview:self.periodLabel];
        [_periodLabel setX:_periodImageView.frame.origin.x + CGRectGetWidth(_periodImageView.bounds) + 5];
        [_periodLabel setY:kHeaderHeight];
        
        [self addSubview:self.businessFinish];
        [_businessFinish setX:10];
        [_businessFinish setY:_periodLabel.frame.origin.y + CGRectGetHeight(_periodLabel.bounds)];
        
        [self addSubview:self.circleChart];
        
        [self addSubview:self.handView];
        [_handView setCenterX:CGRectGetWidth(self.bounds) / 2.0];
        [_handView setY:_circleChart.frame.origin.y + CGRectGetHeight(_circleChart.bounds) - 52.5];
        _handView.layer.anchorPoint = CGPointMake(1.f, 0.5f);
        
        [self addSubview:self.finishRate];
        [_finishRate setY:_circleChart.frame.origin.y + CGRectGetHeight(_circleChart.bounds) - 30 - 10];
    }
    
    if (_chartType == 1002) {
        [self setHeight:kViewHeightType1002];
        
        [self addSubview:self.headerView];
        [self addSubview:self.titleLabel];
        
        [self addSubview:self.infoButton];
        [_infoButton setX:CGRectGetWidth(self.bounds) - CGRectGetWidth(_infoButton.bounds)];
        [_infoButton setHeight:kHeaderHeight];
        [_titleLabel setWidth:CGRectGetWidth(self.bounds) - kHeaderHeight - CGRectGetWidth(_infoButton.bounds)];
        
        [self addSubview:self.lineView];
        
        [self addSubview:self.periodImageView];
        [_periodImageView setX:10];
        [_periodImageView setY:kHeaderHeight + 10];
        
        [self addSubview:self.periodLabel];
        [_periodLabel setX:_periodImageView.frame.origin.x + CGRectGetWidth(_periodImageView.bounds) + 5];
        [_periodLabel setY:kHeaderHeight];
        
        [self addSubview:self.opportunitySourceLabel];
        [_opportunitySourceLabel setY:_periodLabel.frame.origin.y + CGRectGetHeight(_periodLabel.bounds)];
        
        [self addSubview:self.opportunityChart];
        [_opportunityChart setY:CGRectGetHeight(self.bounds) - CGRectGetHeight(_opportunityChart.bounds)];
    }
    
    if (_chartType == 1003) {
        // 设置self的高度
        [self setHeight:kCustomViewHeight];
        
        // 设置periodImageView
        [self addSubview:self.periodImageView];
        [_periodImageView setX:10];
        [_periodImageView setY:10];
        
        // 设置periodLabel
        [self addSubview:self.periodLabel];
        [_periodLabel setX:_periodImageView.frame.origin.x + CGRectGetWidth(_periodImageView.bounds) + 5];
        
        // 设置infoButton
        [self addSubview:self.infoButton];
        [_infoButton setX:CGRectGetWidth(self.bounds) - CGRectGetWidth(_infoButton.bounds)];
        

        // 添加数据描述
        [self addSubview:self.performanceOne];
        [self addSubview:self.performanceTwo];
        
        // 添加竖直图表视图
        [self addSubview:self.verticalBarChart];
    }
    
    if (_chartType == 1004) {
        [self setHeight:kViewHeightType1004];
        
        [self addSubview:self.headerView];
        
        [self addSubview:self.titleLabel];
        
        [self addSubview:self.infoButton];
        [_infoButton setX:CGRectGetWidth(self.bounds) - CGRectGetWidth(_infoButton.bounds)];
        [_infoButton setHeight:kHeaderHeight];
        [_titleLabel setWidth:CGRectGetWidth(self.bounds) - kHeaderHeight - CGRectGetWidth(_infoButton.bounds)];
        
        [self addSubview:self.lineView];
        
        [self addSubview:self.periodImageView];
        [_periodImageView setX:10];
        [_periodImageView setY:kHeaderHeight + 10];
        
        [self addSubview:self.periodLabel];
        [_periodLabel setX:_periodImageView.frame.origin.x + CGRectGetWidth(_periodImageView.bounds) + 5];
        [_periodLabel setY:kHeaderHeight];

        [self addSubview:self.funnelTotal];
        [_funnelTotal setY:_periodLabel.frame.origin.y + CGRectGetHeight(_periodLabel.bounds)];
        
        [self addSubview:self.funnelPart];
        [_funnelPart setY:_funnelTotal.frame.origin.y + CGRectGetHeight(_funnelTotal.bounds)];
        
        [self addSubview:self.funnelView];
        [_funnelView setY:_funnelPart.frame.origin.y + CGRectGetHeight(_funnelPart.bounds) + 10];
    }
    
    if (_chartType == 1005) {
        // 设置self的高度
        [self setHeight:kCustomViewHeight];
        
        // 设置periodImageView
        [self addSubview:self.periodImageView];
        [_periodImageView setX:10];
        [_periodImageView setY:10];
        
        // 设置periodLabel
        [self addSubview:self.periodLabel];
        [_periodLabel setX:_periodImageView.frame.origin.x + CGRectGetWidth(_periodImageView.bounds) + 5];
        
        // 设置infoButton
        [self addSubview:self.infoButton];
        [_infoButton setX:CGRectGetWidth(self.bounds) - CGRectGetWidth(_infoButton.bounds)];
        
        // 添加水平图表视图
        [self addSubview:self.horizontalBarChart];
    }
    
    if (_chartType == 1006) {
        
    }
    
    if (_chartType == 1007) {
        
    }
}

- (void)setPeriodType:(NSString *)periodType {
    if ([periodType isEqualToString:@"week"]) {
        _periodLabel.text = @"本月";
    }else if ([periodType isEqualToString:@"month"]) {
        _periodLabel.text = @"本季度";
    }else if ([periodType isEqualToString:@"year"]) {
        _periodLabel.text = @"本年";
    }
}

- (void)setSourceData:(NSString *)sourceData {
    switch (_chartType) {
        case 1001: {
            NSData *data = [sourceData dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            
            NSInteger value1 = [[self.numberFormatter numberFromString:[NSString stringWithFormat:@"%@", dict[@"actuals"]]] integerValue];
            NSString *valueStr1 = [self.numberFormatter stringFromNumber:[NSNumber numberWithInteger:value1]];
            NSInteger *value2 = (100 * value1/[dict[@"quota"] integerValue]);
            NSString *valueStr2 = [NSString stringWithFormat:@"%d%%", value2];
            
            _businessFinish.attributedText = [self getStringWithTitleOne:@"完成额" andValueOne:[NSString stringWithFormat:@"%@元", valueStr1] andTitleTwo:@"完成度" andValueTwo:valueStr2];
            
            [_finishRate dd_setNumber:@(100 * value1/[dict[@"quota"] integerValue]) format:@"%@%%" formatter:nil];
            
            [UIView animateWithDuration:1.0 animations:^{
                if (value2 <= 100) {
                    _handView.transform = CGAffineTransformMakeRotation(M_PI*floorf((long)value2/(float)100));
                }else {
                    _handView.transform = CGAffineTransformMakeRotation(M_PI);
                }
            }];

        }
            break;
        case 1002: {
            NSData *data = [sourceData dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            
            _opportunitySourceLabel.attributedText = [self getStringWithTitleOne:@"金额" andValueOne:@"2,000,000,000元" andTitleTwo:@"赢率" andValueTwo:@"60%"];
            
            _opportunityChart.minDateString = dict[@"minDate"];
            _opportunityChart.maxDateString = dict[@"maxDate"];
            
            NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:0];
            for (NSDictionary *tempDict in dict[@"data"]) {
                OpportunityChartItem *item = [OpportunityChartItem initWithDictionary:tempDict];
                [tempArray addObject:item];
            }
            _opportunityChart.sourceArray = tempArray;
        }
            break;
        case 1003: {
            NSData *data = [sourceData dataUsingEncoding:NSUTF8StringEncoding];
            _performanceData = [NSArray arrayWithArray:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil]];
            
            _verticalBarChart.dataArray = _performanceData;
            
            NSDictionary *dict = _performanceData[0];
            _performanceOne.attributedText = [self getStringWithTitleOne:@"业绩" andValueOne:[NSString stringWithFormat:@"%@元", dict[@"actuals"]] andTitleTwo:@"目标" andValueTwo:[NSString stringWithFormat:@"%@元", dict[@"quota"]]];
            _performanceTwo.attributedText = [self getStringWithTitleOne:@"拜访" andValueOne:@"0" andTitleTwo:@"电话" andValueTwo:@"0"];
        }
            break;
        case 1004: {
            NSData *data = [sourceData dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            _funnelView.sourceArray = [NSArray arrayWithArray:dict[@"series"]];
            _funnelTotal.attributedText = [self getStringWithTitle:@"总金额" andValue:@"11,285,554元"];
            _funnelPart.attributedText = [self getStringWithTitle:@"初步接洽" andValue:@"10,300元/2个"];
        }
            break;
        case 1005: {
            NSMutableArray *sourceArray = [NSMutableArray arrayWithCapacity:0];
            NSData *data = [sourceData dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            for (NSDictionary *tempDict in dict[@"series"]) {
                ChartDataItem *item = [ChartDataItem initWithDictionary:tempDict];
                [sourceArray addObject:item];
            }
            _horizontalBarChart.dataArray = [NSArray arrayWithArray:sourceArray];
        }
            break;
            
        default:
            break;
    }
}

- (UIImageView*)headerView {
    if(!_headerView) {
        _headerView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, kHeaderHeight - 20, kHeaderHeight - 20)];
        NSString *imageStr = @"https://rs.ingageapp.com/upload/i/151745/329692/s_e822aae387324d5b8862245e8e7ecf4c.jpg";
        [_headerView sd_setImageWithURL:[NSURL URLWithString:imageStr] placeholderImage:nil];
    }
    return _headerView;
}

- (UILabel*)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kHeaderHeight, 10, 0, kHeaderHeight - 20)];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.text = @"张彬";
    }
    return _titleLabel;
}

- (UIView*)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(10, kHeaderHeight - 0.5, CGRectGetWidth(self.bounds) - 20, 0.5)];
        _lineView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0f];
    }
    return _lineView;
}

- (UIButton*)infoButton {
    if (!_infoButton) {
        UIImage *image = [UIImage imageNamed:@"dashboard_detailButton"];
        _infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _infoButton.frame = CGRectMake(0, 0, image.size.width + 20, image.size.height + 20);
        [_infoButton setImage:image forState:UIControlStateNormal];
        [_infoButton addTarget:self action:@selector(infoButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _infoButton;
}

- (UIImageView*)periodImageView {
    if (!_periodImageView) {
        UIImage *periodImage = [UIImage imageNamed:@"dashboard_date"];
        _periodImageView = [[UIImageView alloc] initWithImage:periodImage];
        _periodImageView.frame = CGRectMake(0, 0, periodImage.size.width, periodImage.size.height);
    }
    return _periodImageView;
}

- (UILabel*)periodLabel {
    if (!_periodLabel) {
        _periodLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, CGRectGetHeight(_periodImageView.bounds) + 20)];
        _periodLabel.backgroundColor = [UIColor whiteColor];
        _periodLabel.font = [UIFont systemFontOfSize:14];
        _periodLabel.textAlignment = NSTextAlignmentLeft;
        _periodLabel.textColor = [UIColor blackColor];
        
    }
    return _periodLabel;
}

- (NSNumberFormatter*)numberFormatter {
    if (!_numberFormatter) {
        _numberFormatter = [[NSNumberFormatter alloc] init];
        _numberFormatter.numberStyle = kCFNumberFormatterDecimalStyle;
    }
    return _numberFormatter;
}

- (HorizontalBarChartView*)horizontalBarChart {
    if (!_horizontalBarChart) {
        _horizontalBarChart = [[HorizontalBarChartView alloc] initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.bounds), kCustomViewHeight - 64)];
    }
    return _horizontalBarChart;
}

- (VerticalBarChartView*)verticalBarChart {
    if (!_verticalBarChart) {
        _verticalBarChart = [[VerticalBarChartView alloc] initWithFrame:CGRectMake(0, 100, CGRectGetWidth(self.bounds), kCustomViewHeight - 100)];
    }
    return _verticalBarChart;
}

- (UILabel*)performanceOne {
    if (!_performanceOne) {
        _performanceOne = [[UILabel alloc] initWithFrame:CGRectMake(10, 44, CGRectGetWidth(self.bounds) - 20, 20)];
        _performanceOne.font = [UIFont systemFontOfSize:14];
        _performanceOne.textAlignment = NSTextAlignmentLeft;
    }
    return _performanceOne;
}

- (UILabel*)performanceTwo {
    if (!_performanceTwo) {
        _performanceTwo = [[UILabel alloc] initWithFrame:CGRectMake(10, 44 + 20 + 5, CGRectGetWidth(_performanceOne.bounds), 15)];
        _performanceTwo.font = [UIFont systemFontOfSize:12];
        _performanceTwo.textAlignment = NSTextAlignmentLeft;
    }
    return _performanceTwo;
}

- (UILabel*)businessFinish {
    if (!_businessFinish) {
        _businessFinish = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds) - 20, 20)];
        _businessFinish.textAlignment = NSTextAlignmentLeft;
    }
    return _businessFinish;
}

- (CircleChartView*)circleChart {
    if (!_circleChart) {
        _circleChart = [[CircleChartView alloc] initWithFrame:CGRectMake(0, kHeaderHeight + 64, CGRectGetWidth(self.bounds), kViewHeightType1001 - kHeaderHeight - 64)];
    }
    return _circleChart;
}

#warning 待修改
- (UIView*)handView {
    if (!_handView) {
//        _handView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kCircleChartWidth / 2.0, 3)];
        _handView.backgroundColor = [UIColor blackColor];
    }
    return _handView;
}

- (UILabel*)finishRate {
    if (!_finishRate) {
        _finishRate = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 30)];
        [_finishRate setCenterX:CGRectGetWidth(self.bounds)/2.0];
        _finishRate.backgroundColor = [UIColor clearColor];
        _finishRate.font = [UIFont fontWithName:@"Helvetica-Bold" size:28];
        _finishRate.textAlignment = NSTextAlignmentCenter;
    }
    return _finishRate;
}

- (UILabel*)funnelTotal {
    if (!_funnelTotal) {
        _funnelTotal = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, CGRectGetWidth(self.bounds) - 20, 20)];
        _funnelTotal.textAlignment = NSTextAlignmentLeft;
    }
    return _funnelTotal;
}

- (UILabel*)funnelPart {
    if (!_funnelPart) {
        _funnelPart = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, CGRectGetWidth(self.bounds) - 20, 20)];
        _funnelPart.textAlignment = NSTextAlignmentLeft;
    }
    return _funnelPart;
}

- (FunnelView*)funnelView {
    if (!_funnelView) {
        _funnelView = [[FunnelView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 190)];
        
    }
    return _funnelView;
}

- (UILabel*)opportunitySourceLabel {
    if (!_opportunitySourceLabel) {
        _opportunitySourceLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, CGRectGetWidth(self.bounds) - 20, 20)];
        _opportunitySourceLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _opportunitySourceLabel;
}

- (OpportunityView*)opportunityChart {
    if (!_opportunityChart) {
        _opportunityChart = [[OpportunityView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 186)];
    }
    return _opportunityChart;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
