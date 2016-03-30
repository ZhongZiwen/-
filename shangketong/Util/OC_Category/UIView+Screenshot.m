//
//  UIView+Screenshot.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "UIView+Screenshot.h"

@implementation UIView (Screenshot)

- (UIImage*)convertViewToImage
{
    UIGraphicsBeginImageContext(self.bounds.size);
    // 利用view层次结构并将其绘制到当前的上下文中
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    // 从图形上下文中获取刚刚生产的UIImage
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
@end
