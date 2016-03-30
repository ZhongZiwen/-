//
//  ProductListCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/11/23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductListCell : UITableViewCell

+ (CGFloat)cellHeight;
- (void)configWithObj:(id)obj;
@end
