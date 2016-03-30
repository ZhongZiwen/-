//
//  ActivityRecordWeeklyCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/9/28.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ActivityRecordWeeklyCell.h"

#define kWidth (kScreen_Width - 40 - 25) / 6.0f
#define kHeight 33
#define kTag_axisX 435221
#define kTag_axisY 436523

@interface ActivityRecordWeeklyCell ()

@property (strong, nonatomic) UILabel *title;

@property (strong, nonatomic) NSMutableArray *pointCenterArray; // 保存原点中心点坐标
@property (strong, nonatomic) CAShapeLayer *backgroundLayer;
@property (strong, nonatomic) CAShapeLayer *lineLayer;
@property (strong, nonatomic) CAShapeLayer *pointLayer;
@property (strong, nonatomic) UIBezierPath *linePath;
@property (strong, nonatomic) UIBezierPath *pointPath;

@property (nonatomic) NSInteger maxValue;   // Y轴最大值
@property (nonatomic) CGPoint startPointX;
@property (nonatomic) CGPoint startPointY;
@end

@implementation ActivityRecordWeeklyCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _pointCenterArray = [[NSMutableArray alloc] initWithCapacity:0];
        _startPointX = CGPointMake(20, 44);
        _startPointY = CGPointMake(20, 44 - 10);
        
        [self.contentView addSubview:self.title];
        
        // 添加Y轴刻度值
        for (int i = 0; i < 6; i ++) {
            UILabel *label = [[UILabel alloc] init];
            label.tag = kTag_axisY + i;
            [label setX:_startPointY.x];
            [label setY:_startPointY.y + kHeight * i - 2];
            [label setWidth:15];
            [label setHeight:10];
            label.font = [UIFont systemFontOfSize:9];
            label.textColor = [UIColor iOS7lightGrayColor];
            label.textAlignment = NSTextAlignmentCenter;
            [self.contentView addSubview:label];
            
            if (i == 5) {
                label.text = @"0";
            }
        }
        
        // 添加x轴刻度值
        for (int i = 0; i < 7; i ++) {
            UILabel *label = [[UILabel alloc] init];
            label.tag = kTag_axisX + i;
            [label setX:_startPointX.x + kWidth * i];
            [label setY:_startPointX.y + kHeight * 5];
            [label setWidth:kWidth];
            [label setHeight:15];
            label.font = [UIFont systemFontOfSize:9];
            label.textColor = [UIColor iOS7lightGrayColor];
            label.textAlignment = NSTextAlignmentLeft;
            [self.contentView addSubview:label];
        }
    }
    return self;
}

- (void)configWithModel:(ActivityType *)model {
    _title.text = [NSString stringWithFormat:@"%@: %@", model.name, model.sum];
    
    // 获取七天中的最大值
    _maxValue = 0;
    for (Activity *tempItem in model.activitiesArray) {
        if ([tempItem.number integerValue] > _maxValue) {
            _maxValue = [tempItem.number integerValue];
        }
    }
    // 确定Y轴的最大值
    if (_maxValue % 5 != 0) {
        _maxValue = (_maxValue / 5 + 1) * 5;
    }
    
    // 显示Y轴刻度值
    for (int i = 0; i < 5; i ++) {
        UILabel *label = (UILabel*)[self.contentView viewWithTag:kTag_axisY + i];
        label.text = [NSString stringWithFormat:@"%d", _maxValue - (_maxValue * i / 5)];
    }
    
    // 显示X轴刻度值
    for (int i = 0; i < model.activitiesArray.count; i ++) {
        UILabel *label = (UILabel*)[self.contentView viewWithTag:kTag_axisX + i];
        Activity *activity = model.activitiesArray[i];
        label.text = [activity.oneDay stringMonthDayForLine];
    }
}

- (void)strokeChartWithModel:(ActivityType *)model {
    
    CGMutablePathRef backgroundPath = CGPathCreateMutable();
    // 起始点 原点坐标
    CGPathMoveToPoint(backgroundPath, NULL, _startPointX.x, _startPointX.y + kHeight * 5);
    
    _pointPath = [UIBezierPath bezierPath];
    _linePath = [UIBezierPath bezierPath];
    
    [_pointCenterArray removeAllObjects];
    // 计算圆心坐标，并画圆
    CGPoint pointCenter;
    for (int i = 0; i < model.activitiesArray.count; i ++) {
        
        Activity *activity = model.activitiesArray[i];
        // 确定圆心坐标
        pointCenter.x = _startPointY.x + kWidth * i;
        if (_maxValue) {
            pointCenter.y = _startPointX.y + 5 * kHeight * (1 - [activity.number integerValue] / (CGFloat)_maxValue);
        }else {
            pointCenter.y = _startPointX.y + 5 * kHeight;
        }
        // 画完一个圆之后需要把起始点移到下一个圆的位置，逆时针画圆
        [_pointPath moveToPoint:CGPointMake(pointCenter.x + (3 + 2)/2.0, pointCenter.y)];
        [_pointPath addArcWithCenter:pointCenter radius:3 startAngle:0 endAngle:2 * M_PI clockwise:YES];
        
        [_pointCenterArray addObject:[NSValue valueWithCGPoint:pointCenter]];
    }
    
    // 根据两圆心坐标，画连线
    for (int i = 0; i < _pointCenterArray.count; i ++) {
        if (i == 0) {
            CGPoint firstPoint = ((NSValue*)_pointCenterArray[0]).CGPointValue;
            CGPathAddLineToPoint(backgroundPath, NULL, firstPoint.x, firstPoint.y);
            continue;
        }
        
        // 上一个原点坐标
        CGPoint prePoint = ((NSValue*)_pointCenterArray[i - 1]).CGPointValue;
        // 当前原点坐标
        CGPoint curPoint = ((NSValue*)_pointCenterArray[i]).CGPointValue;
        // 两原点之间的对角线，fabsf取绝对值
        float distance  = sqrtf(powf(curPoint.x - prePoint.x, 2) + powf(curPoint.y - prePoint.y, 2));
        float x = 3 * fabsf(curPoint.x - prePoint.x) / distance;
        float y = 3 * fabsf(curPoint.y - prePoint.y) / distance;
        
        if (prePoint.y > curPoint.y) {
            [_linePath moveToPoint:CGPointMake(prePoint.x + x, prePoint.y - y)];
            [_linePath addLineToPoint:CGPointMake(curPoint.x - x, curPoint.y + y)];
        }else {
            [_linePath moveToPoint:CGPointMake(prePoint.x + x, prePoint.y + y)];
            [_linePath addLineToPoint:CGPointMake(curPoint.x - x, curPoint.y - y)];
        }
        
        CGPathAddLineToPoint(backgroundPath, NULL, curPoint.x, curPoint.y);
        
        if (i == _pointCenterArray.count - 1) {
            CGPathAddLineToPoint(backgroundPath, NULL, curPoint.x, _startPointX.y + kHeight * 5);
        }
    }
    
    CGPathAddLineToPoint(backgroundPath, NULL, _startPointX.x, _startPointX.y + kHeight * 5);
    CGPathCloseSubpath(backgroundPath);
    
    self.backgroundLayer.path = backgroundPath;
    self.lineLayer.path = _linePath.CGPath;
    self.pointLayer.path = _pointPath.CGPath;
    
    CGPathRelease(backgroundPath);

    [self.layer addSublayer:self.backgroundLayer];
    [self.layer addSublayer:self.lineLayer];
    [self.layer addSublayer:self.pointLayer];
    
    [CATransaction begin];
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 1.0;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pathAnimation.fromValue = @0.0f;
    pathAnimation.toValue   = @1.0f;
    
    [self.lineLayer addAnimation:pathAnimation forKey:@"strokeEndAnimation"];
    self.lineLayer.strokeEnd = 2.0;
    
    [CATransaction commit];
}

+ (CGFloat)cellHeight {
    return 250;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - setters and getters
- (UILabel*)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        [_title setX:10];
        [_title setY:5];
        [_title setWidth:kScreen_Width - 10 - 10];
        [_title setHeight:20];
        _title.font = [UIFont systemFontOfSize:16];
        _title.textAlignment = NSTextAlignmentLeft;
        _title.textColor = [UIColor iOS7darkGrayColor];
    }
    return _title;
}

- (CAShapeLayer*)backgroundLayer {
    if (!_backgroundLayer) {
        _backgroundLayer = [CAShapeLayer layer];
        _backgroundLayer.frame = self.bounds;
        _backgroundLayer.fillColor = [UIColor colorWithRed:0.47 green:0.75 blue:0.78 alpha:0.5].CGColor;
        _backgroundLayer.backgroundColor = [UIColor clearColor].CGColor;
        [_backgroundLayer setStrokeColor:[UIColor clearColor].CGColor];
    }
    return _backgroundLayer;
}

- (CAShapeLayer*)lineLayer {
    if (!_lineLayer) {
        _lineLayer = [CAShapeLayer layer];
        _lineLayer.lineCap = kCALineCapButt;
        _lineLayer.lineJoin = kCALineJoinMiter;
        _lineLayer.fillColor = [UIColor iOS7orangeColor].CGColor;
        _lineLayer.lineWidth = 2.f;
        _lineLayer.strokeEnd = 0.0;
        _lineLayer.strokeColor = [UIColor iOS7orangeColor].CGColor;
    }
    return _lineLayer;
}

- (CAShapeLayer*)pointLayer {
    if (!_pointLayer) {
        _pointLayer = [CAShapeLayer layer];
        _pointLayer.lineCap = kCALineCapButt;
        _pointLayer.lineJoin = kCALineJoinMiter;
        _pointLayer.fillColor = nil;
        _pointLayer.lineWidth = 2.f;
        _pointLayer.strokeColor = [UIColor iOS7orangeColor].CGColor;
    }
    return _pointLayer;
}

- (void)drawRect:(CGRect)rect {
    UIColor *axisColor = [UIColor iOS7lightGrayColor];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, axisColor.CGColor);
    CGContextSetLineWidth(context, 0.5f);
    
    // 画横线
    for (int i = 0; i < 6; i ++) {
        CGContextMoveToPoint(context, _startPointX.x, _startPointX.y + kHeight * i);
        CGContextAddLineToPoint(context, kScreen_Width - 20, _startPointX.y + kHeight * i);
    }
    
    // 画竖线
    for (int i = 0; i < 7; i ++) {
        CGContextMoveToPoint(context, _startPointY.x + kWidth * i, _startPointY.y);
        CGContextAddLineToPoint(context, _startPointY.x + kWidth * i, _startPointY.y + kHeight * 5 + 10);
    }
    
    CGContextDrawPath(context, kCGPathStroke);
}

@end
