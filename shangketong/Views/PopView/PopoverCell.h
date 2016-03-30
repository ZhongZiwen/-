//
//  PopoverCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/11/11.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTableViewWidth 150

@interface PopoverCell : UITableViewCell

+ (CGFloat)cellHeight;
- (void)configWithObj:(id)obj;
@end
