//
//  RecordSendTextCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/27.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPlaceHolderTextView.h"

@interface RecordSendTextCell : UITableViewCell

@property (strong, nonatomic) UIPlaceHolderTextView *recordContentView;

+ (CGFloat)cellHeight;
@end
