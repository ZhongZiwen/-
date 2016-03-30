//
//  SKTConditionView.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/17.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SKTCondition;

@interface SKTConditionView : UIButton

- (instancetype)initWithFrame:(CGRect)frame andConditionItem:(SKTCondition*)item;
+ (instancetype)initWithFrame:(CGRect)frame andConditionItem:(SKTCondition*)item;
@end
