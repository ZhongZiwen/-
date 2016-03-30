//
//  SearchResultTwoCell.h
//  shangketong
//
//  Created by 蒋 on 15/7/10.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchResultTwoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgIcon;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

- (void)setFrameForAllPhone;
@end
