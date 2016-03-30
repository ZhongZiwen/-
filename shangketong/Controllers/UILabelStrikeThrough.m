//
//  UILabelStrikeThrough.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/12.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "UILabelStrikeThrough.h"

@implementation UILabelStrikeThrough

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    if (_isWithStrikeThrough)
    {
        CGContextRef c = UIGraphicsGetCurrentContext();
        
        //CGFloat black[4] = {1.0f, 0.0f, 0.0f, 0.8f}; //红色
        CGFloat black[4] = {0.0f, 0.0f, 0.0f, 0.5f};//黑色
        CGContextSetStrokeColor(c, black);
        CGContextSetLineWidth(c, 1);
        CGContextBeginPath(c);
        CGFloat halfWayUp = (self.bounds.size.height - self.bounds.origin.y) / 2.0;
        CGContextMoveToPoint(c, self.bounds.origin.x, halfWayUp );
        CGContextAddLineToPoint(c, self.bounds.origin.x + self.bounds.size.width, halfWayUp);//直线
        // CGContextMoveToPoint(c, self.bounds.origin.x-10, self.bounds.origin.y-10 );
        //CGContextAddLineToPoint(c, (self.bounds.origin.x + self.bounds.size.width)*0.7, self.bounds.origin.y+self.bounds.size.height);  //斜线
        CGContextStrokePath(c);
    }
    
    [super drawRect:rect];
}

@end
