//
//  OpportunityView.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/7/2.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "OpportunityView.h"
#import "NSString+Common.h"
#import "UIView+Common.h"
#import "NSDate+Utils.h"
#import "OpportunityChartItem.h"

#define rgba(r, g, b, a) [UIColor colorWithRed:(float)r / 255.0 green:(float)g / 255.0 blue:(float)b / 255.0 alpha:a]
#define kStepWidth  30

@interface OpportunityView ()

@property (nonatomic, weak) CAShapeLayer *pathLayer;

@property (nonatomic) UIView *axisX;                    
@property (nonatomic) UIView *axisY;
@property (nonatomic) NSMutableArray *axisX_labels;     // 坐标轴x 标签数组
@property (nonatomic) NSMutableArray *axisY_labels;     // 坐标轴y 标签数组
@property (nonatomic) NSMutableArray *pointCenterArray; // 保存分步点的中心点坐标
@property (nonatomic, assign) NSInteger daysCount;      // 最长时间和最短时间相隔多少天

- (void)setAxisYLabel:(NSArray *)array;

- (CGFloat)getPointCenterXWithDateString:(NSString*)dateStr;
- (CGFloat)getPointCenterYWithValue:(NSInteger)yValue;
- (UIColor*)getFillColorWithString:(NSString*)colorStr;
/** 配置x轴线和y轴线的初始位置*/
- (void)configAxis;
/** 根据index 设置x轴线和y轴线的位置*/
- (void)axisAnimateToIndex:(NSInteger)index;
/** 根据pan手势停止移动时最终点，与pointCenterArray中点的中心坐标的距离做比较，给出离最近距离的点*/
- (NSInteger)minDistanceWithPointCenter:(CGPoint)pointCenter;
@end

@implementation OpportunityView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        _axisX_labels = [NSMutableArray array];
        _axisY_labels = [NSMutableArray array];
        _pointCenterArray = [NSMutableArray array];
        
        [self setAxisYLabel:@[@"25%", @"50%", @"75%", @"100%"]];
        
        [self addSubview:self.axisX];
        [self addSubview:self.axisY];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:panGesture];

    }
    return self;
}

#pragma mark - Gesture
- (void)handlePan:(UIPanGestureRecognizer*)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        CGPoint location = [recognizer locationInView:self];
        [_axisX setY:location.y];
        [_axisY setX:location.x];
    }
    
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [recognizer translationInView:self];
        
        CGFloat newX = _axisY.frame.origin.x + translation.x;
        CGFloat newY = _axisX.frame.origin.y + translation.y;
        
        if (newX >= 30 && newX <= CGRectGetWidth(self.bounds) -20) {
            [_axisY setX:newX];
        }
        if (newY >= 0 && newY <= CGRectGetHeight(self.bounds) - 30) {
            [_axisX setY:newY];
        }
        [recognizer setTranslation:CGPointZero inView:self];        
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        NSInteger index = [self minDistanceWithPointCenter:CGPointMake(_axisY.frame.origin.x, _axisX.frame.origin.y)];
        [self axisAnimateToIndex:index];
    }
}

- (void)setSourceArray:(NSArray *)sourceArray {
    _sourceArray = sourceArray;
    
    if (!_sourceArray.count)
        return;
    
    __weak __block typeof(self) weak_self = self;
    __block CGPoint pointCenter;
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    pathAnimation.duration = 1.0f;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pathAnimation.fromValue = @(0.0f);
    pathAnimation.toValue = @(1.0f);
    pathAnimation.fillMode = kCAFillModeForwards;
    self.layer.opacity = 1;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:1];
        dispatch_async(dispatch_get_main_queue(), ^{
            for (OpportunityChartItem *item in sourceArray) {
                pointCenter.x = [self getPointCenterXWithDateString:item.m_dateString];
                pointCenter.y = [self getPointCenterYWithValue:item.m_yValue];
                CAShapeLayer *shape = [self drawingPointsWithX:pointCenter.x andY:pointCenter.y andRadius:item.m_radius andFillColor:item.m_fillColor];
                self.pathLayer = shape;
                [self.layer addSublayer:self.pathLayer];
                [self.pathLayer addAnimation:pathAnimation forKey:@"fade"];
                [weak_self.pointCenterArray addObject:[NSValue valueWithCGPoint:pointCenter]];
            }
            
            [weak_self configAxis];
        });
    });
}

#pragma mark - Private Method
- (void)setAxisYLabel:(NSArray *)array {
    [_axisY_labels removeAllObjects];
    for (int i = 0; i < array.count; i ++) {
        UILabel *label = [[UILabel alloc] init];
        label.text = array[i];
        [_axisY_labels addObject:label];
    }
}

- (void)showXLabel:(UILabel*)xLabel inPosition:(CGPoint)point {
    CGRect frame = CGRectMake(point.x, point.y, 64, 10);
    xLabel.frame = frame;
    xLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:9.0];
    xLabel.textColor = [UIColor colorWithRed:0.4f green:0.4f blue:0.4f alpha:1.f];
    xLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:xLabel];
}

- (void)showYLabel:(UILabel*)yLabel inPosition:(CGPoint)point {
    CGRect frame = CGRectMake(point.x, point.y, 25, 10);
    yLabel.frame = frame;
    yLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:9.0];
    yLabel.textColor = [UIColor colorWithRed:0.4f green:0.4f blue:0.4f alpha:1.f];
    yLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:yLabel];
}

- (CGFloat)getPointCenterXWithDateString:(NSString *)dateStr {
    CGFloat startPointX = 30;
    CGFloat endPointX = CGRectGetWidth(self.bounds) - 20;
    NSDate *endDate = [[NSDate alloc] initWithTimeIntervalSince1970:[dateStr longLongValue] / 1000.0];
    NSDate *startDate = [[NSDate alloc] initWithTimeIntervalSince1970:[_minDateString longLongValue] / 1000.0];
    NSInteger days = [NSDate daysOffsetBetweenStartDate:startDate endDate:endDate];
    
    return 30 + (endPointX - startPointX) * (CGFloat)days / (CGFloat)_daysCount;
}

- (CGFloat)getPointCenterYWithValue:(NSInteger)yValue {
    CGFloat startPointY = CGRectGetHeight(self.bounds)-30;
    return startPointY -  (kStepWidth * 4 + 2) * yValue / 100;
}

- (UIColor*)getFillColorWithString:(NSString *)colorStr {
    NSString *fillColorStr = [colorStr stringByReplacingOccurrencesOfString:@"(" withString:@" "];
    fillColorStr = [fillColorStr stringByReplacingOccurrencesOfString:@")" withString:@""];
    fillColorStr = [fillColorStr stringByReplacingOccurrencesOfString:@"," withString:@""];
    NSArray *array = [fillColorStr componentsSeparatedByString:@" "];

    return [UIColor colorWithRed:(CGFloat)[array[1] floatValue]/255.0 green:(CGFloat)[array[2] floatValue]/255.0 blue:(CGFloat)[array[3] floatValue]/255.0 alpha:[array[4] floatValue]];
}

- (void)configAxis {
    
    if (!_pointCenterArray.count && _pointCenterArray.count != _sourceArray.count)
        return;
    
    NSInteger maxValue = 0;
    int maxValueIndex = 0;
    for (int i = 0; i < _sourceArray.count; i ++) {
        OpportunityChartItem *item = _sourceArray[i];
        if (item.m_yValue > maxValue) {
            maxValue = item.m_yValue;
            maxValueIndex = i;
        }
    }
    
    [self axisAnimateToIndex:maxValueIndex];
    _axisX.hidden = NO;
    _axisY.hidden = NO;
}

- (void)axisAnimateToIndex:(NSInteger)index {
    NSValue *pointValue = _pointCenterArray[index];
    CGPoint point = pointValue.CGPointValue;
    
    [UIView animateWithDuration:0.16 animations:^{
        [_axisX setY:point.y];
        [_axisY setX:point.x];
    }];
}

- (NSInteger)minDistanceWithPointCenter:(CGPoint)pointCenter {
    
    // hypot 求直角三角形的斜边
    // fabs(double i) 处理double类型的取绝对值
    // result的默认值是跟坐标原点的距离
    double result = hypot(fabs(pointCenter.x - ((NSValue*)_pointCenterArray[0]).CGPointValue.x), fabs(pointCenter.y - ((NSValue*)_pointCenterArray[0]).CGPointValue.y));
    int index = 0;
    for (int i = 0; i < _pointCenterArray.count; i ++) {
        CGPoint point = ((NSValue*)_pointCenterArray[i]).CGPointValue;
        double distance = hypot(fabs(pointCenter.x - point.x), fabs(pointCenter.y - point.y));
        if (distance < result) {
            result = hypot(fabs(pointCenter.x - point.x), fabs(pointCenter.y - point.y));
            index = i;
        }
    }
    return index;
}

- (CAShapeLayer*)drawingPointsWithX:(CGFloat)x andY:(CGFloat)y andRadius:(NSInteger)radius andFillColor:(NSString*)fillColorStr
{
    CAShapeLayer *circle = [CAShapeLayer layer];
    circle.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(x, y) radius:(radius == 2 ? 4 : radius) startAngle:0 endAngle:2*M_PI clockwise:YES].CGPath;
    circle.fillColor = [self getFillColorWithString:fillColorStr].CGColor;
    circle.strokeColor = [self getFillColorWithString:fillColorStr].CGColor;
    circle.lineWidth = 0.5f;
    
    return circle;
}

#pragma mark - setters and getters
- (void)setMinDateString:(NSString *)minDateString {
    _minDateString = minDateString;
    
    [_axisX_labels removeAllObjects];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = [NSString transDateWithTimeInterval:minDateString andCustomFormate:@"yyyy-MM-dd"];
    [_axisX_labels addObject:label];
}

- (void)setMaxDateString:(NSString *)maxDateString {
    _maxDateString = maxDateString;
    
    NSDate *endDate = [[NSDate alloc] initWithTimeIntervalSince1970:[maxDateString longLongValue] / 1000.0];
    NSDate *startDate = [[NSDate alloc] initWithTimeIntervalSince1970:[_minDateString longLongValue] / 1000.0];
    _daysCount = [NSDate daysOffsetBetweenStartDate:startDate endDate:endDate];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = [NSString transDateWithTimeInterval:maxDateString andCustomFormate:@"yyyy-MM-dd"];
    [_axisX_labels addObject:label];
}

- (UIView*)axisX {
    if (!_axisX) {
        _axisX = [[UIView alloc] initWithFrame:CGRectMake(30, CGRectGetHeight(self.bounds) - 30, CGRectGetWidth(self.bounds) - 30 - 20, 0.5)];
        _axisX.backgroundColor = [UIColor colorWithRed:0.4f green:0.4f blue:0.4f alpha:1.f];
        _axisX.hidden = YES;
    }
    return _axisX;
}

- (UIView*)axisY {
    if (!_axisY) {
        _axisY = [[UIView alloc] initWithFrame:CGRectMake(30, 0, 0.5, CGRectGetHeight(self.bounds) - 30)];
        _axisY.backgroundColor = [UIColor colorWithRed:0.4f green:0.4f blue:0.4f alpha:1.f];
        _axisY.hidden = YES;
    }
    return _axisY;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    UIColor *axisColor = [UIColor colorWithRed:0.4f green:0.4f blue:0.4f alpha:1.f];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 画x轴、y轴
    CGContextSetStrokeColorWithColor(context, axisColor.CGColor);
    CGContextSetLineWidth(context, 0.5f);
    
    CGPoint startPoint = CGPointMake(30, CGRectGetHeight(self.bounds)-30);
    
    CGPoint endPointVectorX = CGPointMake(CGRectGetWidth(self.bounds) - 20, CGRectGetHeight(self.bounds)-30);

    CGPoint endPointVectorY = CGPointMake(30, 0);
    
    // drawing x vector
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(context, endPointVectorX.x, endPointVectorX.y);
    
    // drawing y vector
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(context, endPointVectorY.x, endPointVectorY.y);
    
    // drawing x arrow vector
    CGContextMoveToPoint(context, endPointVectorX.x, endPointVectorX.y);
    CGContextAddLineToPoint(context, endPointVectorX.x - 5, endPointVectorX.y + 3);
    CGContextMoveToPoint(context, endPointVectorX.x, endPointVectorX.y);
    CGContextAddLineToPoint(context, endPointVectorX.x - 5, endPointVectorX.y - 3);
    
    // drawing y arrow vector
    CGContextMoveToPoint(context, endPointVectorY.x, endPointVectorY.y);
    CGContextAddLineToPoint(context, endPointVectorY.x - 3, endPointVectorY.y + 5);
    CGContextMoveToPoint(context, endPointVectorY.x, endPointVectorY.y);
    CGContextAddLineToPoint(context, endPointVectorY.x + 3, endPointVectorY.y + 5);
    
    // 画y轴刻度、设置y轴标签
    for (int i = 0; i < _axisY_labels.count; i++) {
        CGFloat temp = startPoint.y - (kStepWidth + 0.5) * (i + 1);

        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(startPoint.x - 2, temp)];
        [path addLineToPoint:CGPointMake(startPoint.x + 2, temp)];
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = [path CGPath];
        shapeLayer.strokeColor = axisColor.CGColor;
        shapeLayer.lineWidth = 0.5f;
        shapeLayer.fillColor = axisColor.CGColor;
        [self.layer addSublayer:shapeLayer];
        
        if (i % 2) {
            UILabel *yLabel = _axisY_labels[i];
            [self showYLabel:yLabel inPosition:CGPointMake(startPoint.x - 25 - 5, temp - 5)];
        }
    }
    
    // 设置x轴标签，最大值和最小值
    for (int i = 0; i < _axisX_labels.count; i ++) {
        UILabel *xLabel = _axisX_labels[i];
        if (i == 0) {
            [self showXLabel:xLabel inPosition:CGPointMake(startPoint.x - 20, startPoint.y + 5)];
        }else {
            [self showXLabel:xLabel inPosition:CGPointMake(endPointVectorX.x - 64 + 20, endPointVectorX.y + 5)];
        }
    }
    
    CGContextDrawPath(context, kCGPathStroke);
}


@end
