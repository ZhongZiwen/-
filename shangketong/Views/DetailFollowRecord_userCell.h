//
//  DetailFollowRecord_userCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/8.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

@class Record;

@interface DetailFollowRecord_userCell : UITableViewCell

@property (strong, nonatomic) TTTAttributedLabel *contentLabel;     // 内容
@property (copy, nonatomic) void(^detailBtnClickedBlock)(void);
@property (copy, nonatomic) void(^headerViewClickedBlock)(void);
@property (copy, nonatomic) void(^fileBtnClickedBlock)(void);
@property (copy, nonatomic) void(^positionBtnClickedBlock)(void);


@property (strong, nonatomic) UIViewController *handleVC;    

+ (CGFloat)cellHeightWithObj:(Record*)obj;
- (void)configWithModel:(Record*)model;
@end
