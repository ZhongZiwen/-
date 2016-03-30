//
//  companyGroupCell.m
//  shangketong
//
//  Created by 蒋 on 15/10/16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "companyGroupCell.h"
#import "CompanyGroupModel.h"
#import "CommonFuntion.h"
#import <UIImageView+WebCache.h>

@implementation companyGroupCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)configWithModel:(CompanyGroupModel *)model {
    _groupName.text = model.group_name;
    [_groupIcon sd_setImageWithURL:[NSURL URLWithString:model.group_images] placeholderImage:[UIImage imageNamed:@"depart_icon"]];
}
- (void)setFrameAllPhone {
    CGFloat vX = kScreen_Width - 320;
    self.groupName.frame = [CommonFuntion setViewFrameOffset:self.groupName.frame byX:0 byY:0 ByWidth:vX byHeight:0];
}
@end
