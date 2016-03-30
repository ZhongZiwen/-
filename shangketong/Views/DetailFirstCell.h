//
//  DetailFirstCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/8.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailFirstCell : UITableViewCell

@property (copy, nonatomic) void(^valueBlock)(NSInteger index);

+ (CGFloat)cellHeight;
@end
