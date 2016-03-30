//
//  FilterSlider.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/22.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterSlider : UIControl

@property (copy, nonatomic) NSString *id;

@property (readonly, copy, nonatomic) NSString *value;
@property (readonly, copy, nonatomic) NSString *valueName;

// 用于给filter中的leftValue、rightValue属性赋值
@property (readonly, assign, nonatomic) NSInteger leftValue;
@property (readonly, assign, nonatomic) NSInteger rightValue;

@property (copy, nonatomic) NSString *leftValueTitle;
@property (copy, nonatomic) NSString *rightValueTitle;

- (void)configWithLeftValue:(NSInteger)leftValue rightValue:(NSInteger)rightValue;
- (void)configValue;
@end
