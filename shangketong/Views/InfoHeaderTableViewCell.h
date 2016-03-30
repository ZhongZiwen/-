//
//  InfoHeaderTableViewCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/4/23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoHeaderTableViewCell : UITableViewCell

+ (CGFloat)cellHeight;
- (void)setImageView:(NSString*)imageStr titleLabel:(NSString*)titleStr detailLabel:(NSString*)detailStr;
@end
