//
//  FilterCondition.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/22.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "FilterCondition.h"
#import "Filter.h"
#import "FilterValue.h"
#import "FilterSlider.h"

@implementation FilterCondition

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _itemId = [aDecoder decodeObjectForKey:@"itemId"];
        _itemName = [aDecoder decodeObjectForKey:@"itemName"];
        _itemSearchType = [aDecoder decodeObjectForKey:@"itemSearchType"];
        _columnType = [aDecoder decodeObjectForKey:@"columnType"];
        _value = [aDecoder decodeObjectForKey:@"value"];
        _valueName = [aDecoder decodeObjectForKey:@"valueName"];
        
        _sliderValueId = [aDecoder decodeObjectForKey:@"sliderValueId"];
        _sliderLeftValue = [aDecoder decodeObjectForKey:@"sliderLeftValue"];
        _sliderRightValue = [aDecoder decodeObjectForKey:@"sliderRightValue"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_itemId forKey:@"itemId"];
    [aCoder encodeObject:_itemName forKey:@"itemName"];
    [aCoder encodeObject:_itemSearchType forKey:@"itemSearchType"];
    [aCoder encodeObject:_columnType forKey:@"columnType"];
    [aCoder encodeObject:_value forKey:@"value"];
    [aCoder encodeObject:_valueName forKey:@"valueName"];
    
    [aCoder encodeObject:_sliderValueId forKey:@"sliderValueId"];
    [aCoder encodeObject:_sliderLeftValue forKey:@"sliderLeftValue"];
    [aCoder encodeObject:_sliderRightValue forKey:@"sliderRightValue"];
}

- (instancetype)initWithFilter:(Filter *)filterItem filterValue:(FilterValue *)valueItem {
    self = [super init];
    if (self) {
        _itemId = filterItem.id;
        _itemName = filterItem.itemName;
        _itemSearchType = filterItem.searchType;
        _columnType = filterItem.columnType;
        _value = valueItem.id;
        _valueName = valueItem.name;
    }
    return self;
}

+ (instancetype)initWithFilter:(Filter *)filterItem filterValue:(FilterValue *)valueItem {
    FilterCondition *condition = [[FilterCondition alloc] initWithFilter:filterItem filterValue:valueItem];
    return condition;
}

- (instancetype)initWithFilter:(Filter *)filterItem filterSlider:(FilterSlider *)slider {
    self = [super init];
    if (self) {
        _itemId = filterItem.id;
        _itemName = filterItem.itemName;
        _itemSearchType = filterItem.searchType;
        _columnType = filterItem.columnType;
        
        _value = slider.value;
        _valueName = slider.valueName;
        
        _sliderValueId = slider.id;
        _sliderLeftValue = @(filterItem.leftValue);
        _sliderRightValue = @(filterItem.rightValue);
    }
    return self;
}

+ (instancetype)initWithFilter:(Filter *)filterItem filterSlider:(FilterSlider *)slider {
    FilterCondition *condition = [[FilterCondition alloc] initWithFilter:filterItem filterSlider:slider];
    return condition;
}

@end