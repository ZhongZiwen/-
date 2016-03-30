//
//  LineChartView.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/7/4.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "LineChartView.h"
#import "PNChart.h"
#import <CoreText/CoreText.h>
#import "UIView+Common.h"

@interface LineChartView ()

@property (nonatomic, strong) UIView *lineView;                 // 选择标杆
@property (nonatomic, strong) NSMutableArray *yValueArray;
@property (nonatomic, strong) NSMutableArray *pointCenterArray; // 保存原点中心点坐标

@property (nonatomic, strong) NSMutableArray *axisX_labels;
@property (nonatomic, strong) NSMutableArray *axisY_labels;

@property (nonatomic, strong) CAShapeLayer *lineLayer;
@property (nonatomic, strong) CAShapeLayer *pointLayer;
@property (nonatomic, strong) UIBezierPath *linePath;
@property (nonatomic, strong) UIBezierPath *pointPath;

@property (nonatomic) NSInteger yValueMin;
@property (nonatomic) NSInteger yValueMax;
@property (nonatomic) CGFloat axisXStepWidth;
@property (nonatomic) CGFloat axisYStepWidth;

/** 坐标轴原点*/
@property (nonatomic) CGPoint startPoint;
/** x轴结束坐标*/
@property (nonatomic) CGPoint endPointX;
/** y轴结束坐标*/
@property (nonatomic) CGPoint endPointY;
@end

@implementation LineChartView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        _axisX_labels = [NSMutableArray arrayWithCapacity:0];
        _axisY_labels = [NSMutableArray arrayWithCapacity:0];
        _yValueMin = 0;
        _yValueMax = 0;
        
        _startPoint = CGPointMake(35, CGRectGetHeight(self.bounds) - 44);
        _endPointX = CGPointMake(CGRectGetWidth(self.bounds) - 10, _startPoint.y);
        _endPointY = CGPointMake(_startPoint.x, 10);
        _axisYStepWidth = 25;
        _axisXStepWidth = (CGRectGetWidth(self.bounds) - _startPoint.x - 30) / 12.0;

        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:panGesture];
    }
    return self;
}

#pragma mark - Gesture
- (void)handlePan:(UIPanGestureRecognizer*)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        CGPoint location = [recognizer locationInView:self];
        [_lineView setCenterX:location.x];
    }
    
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [recognizer translationInView:self];
        
        CGFloat newX = _lineView.center.x + translation.x;
        
        if (newX >= _startPoint.x && newX <= _endPointX.x) {
            [_lineView setCenterX:newX];
        }
        [recognizer setTranslation:CGPointZero inView:self];
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        NSInteger index = [self minDistanceWithPointCenter:_lineView.center.x];
        [self lineViewAnimateToIndex:index];
    }
}

- (NSInteger)minDistanceWithPointCenter:(CGFloat)x {

    CGFloat minDistance = MAXFLOAT;
    int index = 0;
    for (int i = 0; i < _pointCenterArray.count; i ++) {
        CGPoint point = ((NSValue*)_pointCenterArray[i]).CGPointValue;
        CGFloat distance = fabsf(x - point.x);
        if (distance < minDistance) {
            minDistance = distance;
            index = i;
        }
    }
    return index;
}

- (void)lineViewAnimateToIndex:(NSInteger)index {
    NSValue *pointValue = _pointCenterArray[index];
    CGPoint point = pointValue.CGPointValue;
    
    [UIView animateWithDuration:0.1 animations:^{
        [_lineView setCenterX:point.x];
    }];
}

#pragma mark - Public Method
- (void)configWithDataSource:(NSArray *)sourceArray {
    if (!sourceArray.count)
        return;
    
    _yValueArray = [NSMutableArray arrayWithCapacity:sourceArray.count];
    
    for (int i = 0; i < sourceArray.count; i ++) {
        NSDictionary *tempDict = sourceArray[i];
        
        [_yValueArray addObject:tempDict[@"money"]];
        
        // 获取最大值
        if ([tempDict[@"money"] integerValue] > _yValueMax) {
            _yValueMax = [tempDict[@"money"] integerValue];
        }
        
        // 初始化x轴标签
        UILabel *xLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 35, 10)];
        xLabel.text = tempDict[@"periodName"];
        [_axisX_labels addObject:xLabel];
    }
    
    //  初始化y轴标签
    for (int i = 0; i < 5; i ++) {
        UILabel *yLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 10)];
        yLabel.text = [NSString stringWithFormat:@"%d", _yValueMax * (i + 1) / 5];
        [_axisY_labels addObject:yLabel];
    }
    
    [self setNeedsDisplay];
}

- (void)strokeChart {
    
    _linePath = [UIBezierPath bezierPath];
    _pointPath = [UIBezierPath bezierPath];
    
    [self calculatePointPath:_pointPath];
    [self calculateLinePath:_linePath];
    
    // 设置标杆的坐标
    CGPoint point = ((NSValue*)_pointCenterArray.lastObject).CGPointValue;
    [self.lineView setCenterX:point.x];
    [self addSubview:self.lineView];
    
    self.lineLayer.path = _linePath.CGPath;
    self.pointLayer.path = _pointPath.CGPath;
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
    
//    [self.pointLayer addAnimation:pathAnimation forKey:@"strokeEndAnimation"];
    
    [CATransaction commit];
}

#pragma mark - Private Method
- (CGFloat)getPointCenterXWithIndex:(NSInteger)index {
    return _startPoint.x + (_axisXStepWidth + 0.5) * (index + 1);
}

- (CGFloat)getPointCenterYWithValue:(NSInteger)value {
    if (value > 0) {
        if ((CGFloat)(_axisYStepWidth + 0.5) * 5 * value / _yValueMax < 6) {
            return _startPoint.y - 6;
        }else {
            return _startPoint.y - (CGFloat)(_axisYStepWidth + 0.5) * 5 * value / _yValueMax;
        }
    }else {
        return _startPoint.y - 6;
    }
}

- (void)calculatePointPath:(UIBezierPath*)pointPath {
    
    _pointCenterArray = [NSMutableArray arrayWithCapacity:_yValueArray.count];
    CGPoint pointCenter;
    for (int i = 0; i < _yValueArray.count; i ++) {
        NSInteger yValue = [_yValueArray[i] integerValue];
        if (yValue >= 0) {
            pointCenter.x = [self getPointCenterXWithIndex:i];
            pointCenter.y = [self getPointCenterYWithValue:yValue];
            
            // 画完一个圆之后需要把起始点移到下一个圆的位置，逆时针画圆
            [_pointPath moveToPoint:CGPointMake(pointCenter.x + (3 + 2)/2.0, pointCenter.y)];
            [pointPath addArcWithCenter:pointCenter radius:3 startAngle:0 endAngle:2 * M_PI clockwise:YES];
            
            [_pointCenterArray addObject:[NSValue valueWithCGPoint:pointCenter]];
        }
    }
}

- (void)calculateLinePath:(UIBezierPath*)linePath {
    
    for (int i = 0; i < _pointCenterArray.count; i ++) {
        if (i != 0) {
            // 上一个原点坐标
            CGPoint prePoint = ((NSValue*)_pointCenterArray[i - 1]).CGPointValue;
            // 当前原点坐标
            CGPoint curPoint = ((NSValue*)_pointCenterArray[i]).CGPointValue;
            // 两原点之间的对角线，fabsf取绝对值
            float distance  = sqrtf(powf(curPoint.x - prePoint.x, 2) + powf(curPoint.y - prePoint.y, 2));
            float x = 3 * fabsf(curPoint.x - prePoint.x) / distance;
            float y = 3 * fabsf(curPoint.y - prePoint.y) / distance;
            
            if (prePoint.y > curPoint.y) {
                [linePath moveToPoint:CGPointMake(prePoint.x + x, prePoint.y - y)];
                [linePath addLineToPoint:CGPointMake(curPoint.x - x, curPoint.y + y)];
            }else {
                [linePath moveToPoint:CGPointMake(prePoint.x + x, prePoint.y + y)];
                [linePath addLineToPoint:CGPointMake(curPoint.x - x, curPoint.y - y)];
            }
        }
    }
}

- (void)showXLabel:(UILabel*)xLabel inCenterPosition:(CGPoint)point {
    [xLabel setCenter:point];
    xLabel.transform = CGAffineTransformMakeRotation(-M_PI/4);
    xLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:9.0];
    xLabel.textColor = [UIColor colorWithRed:0.4f green:0.4f blue:0.4f alpha:1.f];
    xLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:xLabel];
}

- (void)showYLabel:(UILabel*)yLabel inCenterPosition:(CGPoint)point {
    [yLabel setCenter:point];
    yLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:9.0];
    yLabel.textColor = [UIColor colorWithRed:0.4f green:0.4f blue:0.4f alpha:1.f];
    yLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:yLabel];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    UIColor *axisColor = [UIColor colorWithRed:0.4f green:0.4f blue:0.4f alpha:1.f];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, axisColor.CGColor);
    CGContextSetLineWidth(context, 0.5f);
    
    // 画x轴
    CGContextMoveToPoint(context, _startPoint.x, _startPoint.y);
    CGContextAddLineToPoint(context, _endPointX.x, _endPointX.y);
    
    // 画y轴
    CGContextMoveToPoint(context, _startPoint.x, _startPoint.y);
    CGContextAddLineToPoint(context, _endPointY.x, _endPointY.y);
    
    // 画x轴箭头
    CGContextMoveToPoint(context, _endPointX.x, _endPointX.y);
    CGContextAddLineToPoint(context, _endPointX.x - 5, _endPointX.y + 3);
    CGContextMoveToPoint(context, _endPointX.x, _endPointX.y);
    CGContextAddLineToPoint(context, _endPointX.x - 5, _endPointX.y - 3);
    
    // 画y轴箭头
    CGContextMoveToPoint(context, _endPointY.x, _endPointY.y);
    CGContextAddLineToPoint(context, _endPointY.x - 3, _endPointY.y + 5);
    CGContextMoveToPoint(context, _endPointY.x, _endPointY.y);
    CGContextAddLineToPoint(context, _endPointY.x + 3, _endPointY.y + 5);
    
    // 画x轴刻度，设置x轴标签
    for (int i = 0; i < _axisX_labels.count; i ++) {
        CGFloat temp = _startPoint.x + (_axisXStepWidth + 0.5) * (i + 1);
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(temp, _startPoint.y - 2)];
        [path addLineToPoint:CGPointMake(temp, _startPoint.y + 2)];
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = path.CGPath;
        shapeLayer.strokeColor = axisColor.CGColor;
        shapeLayer.lineWidth = 0.5f;
        shapeLayer.fillColor = axisColor.CGColor;
        [self.layer addSublayer:shapeLayer];
        
        UILabel *xLabel = _axisX_labels[i];
        [self showXLabel:xLabel inCenterPosition:CGPointMake(temp - 10, _startPoint.y + 20)];
    }
    
    // 画y轴刻度，设置y轴标签
    for (int i = 0; i < _axisY_labels.count; i ++) {
        CGFloat temp = _startPoint.y - (_axisYStepWidth + 0.5) * (i + 1);
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(_startPoint.x - 2, temp)];
        [path addLineToPoint:CGPointMake(_startPoint.x + 2, temp)];
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = [path CGPath];
        shapeLayer.strokeColor = axisColor.CGColor;
        shapeLayer.lineWidth = 0.5f;
        shapeLayer.fillColor = axisColor.CGColor;
        [self.layer addSublayer:shapeLayer];
        
        UILabel *yLabel = _axisY_labels[i];
        [self showYLabel:yLabel inCenterPosition:CGPointMake(_startPoint.x / 2.0, temp)];
    }
    
    CGContextDrawPath(context, kCGPathStroke);
}

#pragma mark - setters and getters
- (UIView*)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, 1, CGRectGetHeight(self.bounds) - 20)];
        _lineView.backgroundColor = PNGreen;
    }
    return _lineView;
}

- (CAShapeLayer*)lineLayer {
    if (!_lineLayer) {
        _lineLayer = [CAShapeLayer layer];
        _lineLayer.lineCap = kCALineCapButt;
        _lineLayer.lineJoin = kCALineJoinMiter;
        _lineLayer.fillColor = PNGreen.CGColor;
        _lineLayer.lineWidth = 2.f;
        _lineLayer.strokeEnd = 0.0;
        _lineLayer.strokeColor = PNGreen.CGColor;
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
        _pointLayer.strokeColor = PNGreen.CGColor;
    }
    return _pointLayer;
}

@end
