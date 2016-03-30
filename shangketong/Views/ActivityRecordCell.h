//
//  ActivityRecordCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/11/18.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

@class Record;

@interface ActivityRecordCell : UITableViewCell

@property (strong, nonatomic) TTTAttributedLabel *contentLabel;

@property (copy, nonatomic) void(^moreBtnClickedBlock)(void);
@property (copy, nonatomic) void(^forwardBlock)(void);
@property (copy, nonatomic) void(^likeBlock)(void);
@property (copy, nonatomic) void(^commentBlock)(void);

+ (CGFloat)cellHeightWithObj:(Record*)obj;
- (void)configWithObj:(Record*)obj;
@end
