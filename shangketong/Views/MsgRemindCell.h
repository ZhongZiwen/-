//
//  MsgRemindCell.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/29.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RemindModel;

@interface MsgRemindCell : UITableViewCell

+ (CGFloat)cellHeightWithModel:(RemindModel*)model;
- (void)configWithModel:(RemindModel*)model;
@end
