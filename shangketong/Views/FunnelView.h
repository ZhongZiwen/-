//
//  FunnelView.h
//  shangketong
//
//  Created by sungoin-zbs on 15/7/9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FunnelView : UIView

@property (nonatomic, strong) NSArray *sourceArray;

- (id)initWithFrame:(CGRect)frame withSlider:(BOOL)isNeed;
@end

#warning 待修改
// 画梯形
@interface DrawTrapeziumViewOther : UIView

@property (nonatomic, strong) UIColor *drawColor;
@property (nonatomic, assign) CGFloat bottomWidth;
@property (nonatomic, assign) CGFloat part;
@end