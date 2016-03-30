//
//  UIView+Screenshot.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Screenshot)

/**
 * 要实现模糊效果，首先是将当前屏幕中的view转换为一副图片。获得图片之后，只需要对图片做模糊处理就可以了。
 *
 * UIView的一个category中，本方法是实现view的截屏逻辑*/

/**
 * 对view截屏
 */
- (UIImage*)convertViewToImage;
@end
