//
//  RecordDetail_commentCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/19.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITapImageView.h"
#import "TTTAttributedLabel.h"

@class Comment;

@interface RecordDetail_commentCell : UITableViewCell

@property (strong, nonatomic) UITapImageView *iconImageView;
@property (strong, nonatomic) TTTAttributedLabel *contentLabel;

+ (CGFloat)cellHeightWithObj:(Comment*)obj;
- (void)configWithObj:(Comment*)obj;
@end
