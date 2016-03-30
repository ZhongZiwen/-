//
//  CustomerTableViewCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/9/23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SWTableViewCell.h"

@class Customer;

@interface CustomerTableViewCell : SWTableViewCell

+ (CGFloat)cellHeight;
- (void)configWithModel:(Customer*)item;
- (void)configWithoutSWWithItem:(Customer*)item;
@end
