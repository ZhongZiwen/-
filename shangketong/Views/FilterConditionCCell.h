//
//  FilterConditionCCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/22.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FilterCondition;

@interface FilterConditionCCell : UICollectionViewCell

- (void)configWithModel:(FilterCondition*)condition;
@end
