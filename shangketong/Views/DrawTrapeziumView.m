//
//  DrawTrapeziumView.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/7/1.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "DrawTrapeziumView.h"

@interface DrawTrapeziumView ()

@property (nonatomic, assign) CGFloat part;
@end

@implementation DrawTrapeziumView

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
