//
//  MsgNotificationTableViewCell.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MsgNotificationTableViewCell : UITableViewCell

+ (CGFloat)cellHeight;
- (void)configImageView:(NSString*)imageStr andTitleLabel:(NSString*)titleStr andBadge:(NSInteger)count;
@end
