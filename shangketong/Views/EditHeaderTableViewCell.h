//
//  EditHeaderTableViewCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/5/5.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditHeaderTableViewCell : UITableViewCell

+ (CGFloat)cellHeight;
- (void)setTitleLabel:(NSString *)titleStr headerImageView:(UIImage *)image;
@end
