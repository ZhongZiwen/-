//
//  TitleImageCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/4/22.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TitleImageCell : UITableViewCell

+ (CGFloat)cellHeight;
- (void)setImageView:(NSString*)imageStr titleLabel:(NSString*)titleStr;
@end
