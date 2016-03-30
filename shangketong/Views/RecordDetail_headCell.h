//
//  RecordDetail_headCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/19.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

@class Record;

@interface RecordDetail_headCell : UITableViewCell

@property (copy, nonatomic) void(^headerViewTapBlock)(void);
@property (copy, nonatomic) void(^positionBlock)(void);
@property (copy, nonatomic) void(^fileBlock)(void);

@property (strong, nonatomic) TTTAttributedLabel *contentLabel;     // 内容
@property (strong, nonatomic) TTTAttributedLabel *timeAndfromLabel; // 来源

@property (strong, nonatomic) UIViewController *handleVC;  

+ (CGFloat)cellHeightWithObj:(Record*)obj;
- (void)configWithModel:(Record*)model;
@end
