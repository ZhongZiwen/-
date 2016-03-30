//
//  FilterCondition.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/22.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Filter, FilterValue, FilterIndexPath, FilterSlider;

@interface FilterCondition : NSObject<NSCoding>

@property (copy, nonatomic) NSString *itemId;
@property (copy, nonatomic) NSString *itemName;
@property (strong, nonatomic) NSNumber *itemSearchType;
@property (strong, nonatomic) NSNumber *columnType;
@property (copy, nonatomic) NSString *value;
@property (copy, nonatomic) NSString *valueName;

@property (copy, nonatomic) NSString *sliderValueId;
@property (strong, nonatomic) NSNumber *sliderLeftValue;
@property (strong, nonatomic) NSNumber *sliderRightValue;

+ (instancetype)initWithFilter:(Filter*)filterItem filterValue:(FilterValue*)valueItem;
- (instancetype)initWithFilter:(Filter*)filterItem filterValue:(FilterValue*)valueItem;

+ (instancetype)initWithFilter:(Filter *)filterItem filterSlider:(FilterSlider*)slider;
- (instancetype)initWithFilter:(Filter *)filterItem filterSlider:(FilterSlider*)slider;
@end
