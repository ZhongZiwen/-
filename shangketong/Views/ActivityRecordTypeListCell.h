//
//  ActivityRecordTypeListCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/11/18.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Activity;

@interface ActivityRecordTypeListCell : UITableViewCell

+ (CGFloat)cellHeight;
- (void)configWithModel:(Activity*)item;
@end
