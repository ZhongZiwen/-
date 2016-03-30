//
//  FunnelView.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "FunnelView.h"
#import "UIView+Common.h"
#import "NSString+Common.h"

#import "StepSlider.h"

#define kMaxWidth 192

@interface FunnelView ()

@property (nonatomic, strong) StepSlider *stepSlider;
@property (nonatomic, strong) NSMutableArray *stepLocationArray;
@property (nonatomic, strong) NSMutableArray *stepConditionArray;
@end

@implementation FunnelView

- (id)initWithFrame:(CGRect)frame withSlider:(BOOL)isNeed {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        _stepLocationArray = [NSMutableArray arrayWithCapacity:0];
        _stepConditionArray = [NSMutableArray arrayWithCapacity:0];
        
        UIColor *color1 = [UIColor colorWithRed:(CGFloat)152/255 green:(CGFloat)206/255 blue:(CGFloat)106/255 alpha:1.0f];
        UIColor *color2 = [UIColor colorWithRed:(CGFloat)253/255 green:(CGFloat)169/255 blue:(CGFloat)99/255 alpha:1.0f];
        UIColor *color3 = [UIColor colorWithRed:(CGFloat)249/255 green:(CGFloat)101/255 blue:(CGFloat)115/255 alpha:1.0f];
        UIColor *color4 = [UIColor colorWithRed:(CGFloat)63/255 green:(CGFloat)148/255 blue:(CGFloat)185/255 alpha:1.0f];
        UIColor *color5 = [UIColor colorWithRed:(CGFloat)115/255 green:(CGFloat)194/255 blue:(CGFloat)241/255 alpha:1.0f];
        UIColor *color6 = [UIColor colorWithRed:(CGFloat)132/255 green:(CGFloat)217/255 blue:(CGFloat)225/255 alpha:1.0f];
        
        NSArray *colorArray = @[color1, color2, color3, color4, color5, color6];
        CGFloat originY = 10;
        CGFloat width = kMaxWidth;
        int arrayCount = 8;
        for (int i = 0; i < arrayCount; i++) {
            
            if (i == 7) {
                UIView *rectangle = [[UIView alloc] initWithFrame:CGRectMake(0, originY, width, CGRectGetHeight(self.bounds)-originY-10)];
                [rectangle setCenterX:CGRectGetWidth(self.bounds) / 2.0];
                rectangle.backgroundColor = colorArray[(arrayCount-1-i)%6];
                [rectangle setCenterX:CGRectGetWidth(self.bounds)/2];
                [self addSubview:rectangle];
                
                [_stepLocationArray addObject:@(rectangle.frame.origin.y + CGRectGetHeight(rectangle.bounds)/2.0)];
                [_stepConditionArray addObject:@(rectangle.frame.origin.y + CGRectGetHeight(rectangle.bounds))];
                
                break;
            }
            
            DrawTrapeziumViewOther *drawView = [[DrawTrapeziumViewOther alloc] initWithFrame:CGRectMake(0, originY, width, (i == 3 ? 100 : 10))];
            [drawView setCenterX:CGRectGetWidth(self.bounds) / 2.0];
            drawView.drawColor = colorArray[(arrayCount-1-i)%6];
            [drawView setCenterX:CGRectGetWidth(self.bounds)/2];
            [self addSubview:drawView];
            
            [_stepLocationArray addObject:@(drawView.frame.origin.y + CGRectGetHeight(drawView.bounds)/2.0)];
            [_stepConditionArray addObject:@(drawView.frame.origin.y + CGRectGetHeight(drawView.bounds))];
            
            originY += CGRectGetHeight(drawView.bounds);
            width = drawView.bottomWidth;
        }
        
        
        if (isNeed) {
            [self addSubview:self.stepSlider];
            _stepSlider.locationArray = _stepLocationArray;
            _stepSlider.conditionArray = _stepConditionArray;
        }
    }
    return self;
}

#pragma mark - setters and getters
- (void)setSourceArray:(NSArray *)sourceArray {
    
    if (!sourceArray.count)
        return;
    
    _sourceArray = sourceArray;
}

- (StepSlider*)stepSlider {
    if (!_stepSlider) {
        _stepSlider = [[StepSlider alloc] initWithFrame:CGRectZero];
        _stepSlider.transform = CGAffineTransformMakeRotation(M_PI/2);
        _stepSlider.frame = CGRectMake(CGRectGetWidth(self.bounds) - 64, 0, 64, CGRectGetHeight(self.bounds));
        _stepSlider.thumbImageString = @"dashboard_Funnel_Slider_MoveView";
        _stepSlider.sliderValueBlock = ^(NSInteger value) {
            NSLog(@"slider value = %d", value);
        };
    }
    return _stepSlider;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

@implementation DrawTrapeziumViewOther

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.part = CGRectGetHeight(self.bounds)/2.2;
        self.bottomWidth = CGRectGetWidth(self.bounds) - 2*_part;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    // 获取上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 定义画笔的宽度
    CGContextSetLineWidth(context, 0.5);
    
    // 定义画笔的颜色
    CGContextSetStrokeColorWithColor(context, _drawColor.CGColor);
    
    // 设置起始点
    CGContextMoveToPoint(context, 0, 0);
    // 画该点与上一个点的连线（下面一次类推）
    CGContextAddLineToPoint(context, CGRectGetWidth(self.bounds), 0);
    CGContextAddLineToPoint(context, CGRectGetWidth(self.bounds)-_part, CGRectGetHeight(self.bounds));
    CGContextAddLineToPoint(context, _part, CGRectGetHeight(self.bounds));
    CGContextAddLineToPoint(context, 0, 0);
    
    // 设置填充颜色
    CGContextSetFillColorWithColor(context, _drawColor.CGColor);
    CGContextFillPath(context);
}

@end