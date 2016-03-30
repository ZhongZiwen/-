//
//  DrawRectangleView.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/7/1.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "DrawRectangleView.h"

@implementation DrawRectangleView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 1.0);
    
    CGContextSetStrokeColorWithColor(context, _drawColor.CGColor);
    
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, CGRectGetWidth(self.bounds), 0);
    CGContextAddLineToPoint(context, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    CGContextAddLineToPoint(context, CGRectGetHeight(self.bounds), 0);
    CGContextAddLineToPoint(context, 0, 0);
    
    CGContextSetFillColorWithColor(context, _drawColor.CGColor);
    CGContextFillPath(context);
}
*/

@end
