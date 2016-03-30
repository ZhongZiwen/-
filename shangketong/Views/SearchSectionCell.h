//
//  SearchSectionCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/12.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchSectionCell : UITableViewCell

+ (CGFloat)cellHeight;
- (void)configWithTitle:(NSString*)string;
@end
