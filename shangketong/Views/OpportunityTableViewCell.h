//
//  OpportunityTableViewCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/9/23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SWTableViewCell.h"

@class SaleChance;

@interface OpportunityTableViewCell : SWTableViewCell

+ (CGFloat)cellHeight;
- (void)configWithModel:(SaleChance*)model;
@end
