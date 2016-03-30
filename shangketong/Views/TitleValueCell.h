//
//  TitleValueCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/4/23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TitleValueCell : UITableViewCell

+ (CGFloat)cellHeightWith:(NSString*)string;
- (void)setTitleLabel:(NSString*)titleStr valueLabel:(NSString*)valueStr;
@end
