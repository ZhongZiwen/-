//
//  AnnounceCell.h
//  shangketong
//
//  Created by 蒋 on 15/9/29.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AnnounceModel;

@interface AnnounceCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;
@property (weak, nonatomic) IBOutlet UILabel *flagLabel;


- (void)setFrameAllPhone;
- (void)configWithModel:(AnnounceModel *)model;
@end
