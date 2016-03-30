//
//  PoolReturnTitleCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/11/12.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PoolReturnTitleCell : UITableViewCell

+ (CGFloat)cellHeightWithString:(NSString*)str;
- (void)configWithString:(NSString*)str;
@end
