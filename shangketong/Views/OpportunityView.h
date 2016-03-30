//
//  OpportunityView.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/7/2.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpportunityChartItem;

@interface OpportunityView : UIControl

@property (nonatomic, copy) NSString *minDateString;
@property (nonatomic, copy) NSString *maxDateString;
@property (nonatomic, strong) NSArray *sourceArray;
@property (nonatomic, copy) void(^selectedBlock) (OpportunityChartItem*);
@end
