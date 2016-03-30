//
//  DetailFollowRecord_systemCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/8.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Record;

@interface DetailFollowRecord_systemCell : UITableViewCell

+ (CGFloat)cellHeight;
- (void)configWithModel:(Record*)model;
@end