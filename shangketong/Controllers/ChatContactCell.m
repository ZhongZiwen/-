//
//  ChatContactCell.m
//  shangketong
//
//  Created by 蒋 on 15/8/31.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ChatContactCell.h"
#import <UIImageView+WebCache.h>

@implementation ChatContactCell

- (void)awakeFromNib {
    // Initialization code
    self.imgIcon.layer.masksToBounds = YES;
    self.imgIcon.layer.cornerRadius = 4;
    self.imgIcon.transform = CGAffineTransformMakeRotation(M_PI / 2);
}

- (void)configWithModel:(ContactModel *)model
{
    if (model.isDefault) {
        [_imgIcon setImage:[UIImage imageNamed:model.imgHeaderName]];
    }else{
        [_imgIcon sd_setImageWithURL:[NSURL URLWithString:model.imgHeaderName] placeholderImage:[UIImage imageNamed:@"user_icon_default"]];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
