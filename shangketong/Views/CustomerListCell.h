//
//  CustomerListCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/11/2.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomerListCell : UITableViewCell

@property (copy, nonatomic) void(^photoBlock)(void);

+ (CGFloat)cellHeight;
- (void)configWithObj:(id)obj;
@end
