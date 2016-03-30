//
//  OpportunityIndicatorCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/9/25.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IndexCondition;

@interface OpportunityIndicatorCell : UITableViewCell

@property (copy, nonatomic) void(^valueBlock) (id data, NSError *error);

+ (CGFloat)cellHeight;
- (void)beginLoadingWithNavIndex:(IndexCondition*)index stageId:(NSNumber*)stageId;
@end
