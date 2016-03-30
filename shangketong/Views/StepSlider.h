//
//  StepSlider.h
//  shangketong
//
//  Created by sungoin-zbs on 15/7/9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StepSlider : UIControl

/** 布点坐标*/
@property (nonatomic, strong) NSArray *locationArray;

/** 坐标条件数组*/
@property (nonatomic, strong) NSArray *conditionArray;

/** 滑杆图片*/
@property (nonatomic, copy) NSString *thumbImageString;

@property (nonatomic, copy) void(^sliderValueBlock) (NSInteger);

@end
