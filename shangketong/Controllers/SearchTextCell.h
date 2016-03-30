//
//  SearchTextCell.h
//  shangketong
//
//  Created by 蒋 on 15/7/10.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchTextCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *searchLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imgIcon;
- (void)setFrameForAllPhone;
@end
