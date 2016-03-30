//
//  MeBusinessHeadCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/7/8.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MeBusinessHeadCell : UITableViewCell

@property (nonatomic, copy) void(^conditionBlock) (UIButton*);

+ (CGFloat)cellHeight;
@end
