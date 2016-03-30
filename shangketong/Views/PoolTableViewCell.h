//
//  PoolTableViewCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/9/26.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PoolGroup;

@interface PoolTableViewCell : UITableViewCell

+ (CGFloat)cellHeight;
- (void)configWithModel:(PoolGroup*)group;
@end
