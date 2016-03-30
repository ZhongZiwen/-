//
//  SelectedBackgroundView.m
//  shangketong
//
//  Created by sungoin-zbs on 15/9/17.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SelectedBackgroundView.h"

@implementation SelectedBackgroundView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    //画一条底部线
    
    CGContextSetRGBStrokeColor(context, 219.0/255, 224.0/255, 228.0/255, 1);//线条颜色
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, rect.size.width,0);
    CGContextMoveToPoint(context, 0, rect.size.height);
    CGContextAddLineToPoint(context, rect.size.width,rect.size.height);
    CGContextStrokePath(context);
}


@end
