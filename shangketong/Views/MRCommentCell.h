//
//  MRCommentCell.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/1.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRCommentModel;

@interface MRCommentCell : UITableViewCell

+ (CGFloat)cellHeightWithModel:(MRCommentModel*)model;
- (void)configWithModel:(MRCommentModel*)model;
@end
