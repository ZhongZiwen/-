//
//  ChatContactDetalsCell.m
//  shangketong
//
//  Created by 蒋 on 15/8/31.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ChatContactDetalsCell.h"
#import "ContactModel.h"
#import "CommonFuntion.h"
#import <UIImageView+WebCache.h>

@implementation ChatContactDetalsCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)configWithModel:(ContactModel *)model {
    _nameLabel.text = model.contactName;
    
    NSString *departAndposition = @"";
    if ([CommonFuntion checkNullForValue:model.departmentName]) {
        departAndposition = model.departmentName;
    }
    if ([CommonFuntion checkNullForValue:model.positionName]) {
        if ([departAndposition isEqualToString:@""]) {
            departAndposition = model.positionName;
        } else {
            departAndposition = [NSString stringWithFormat:@"%@ | %@", departAndposition, model.positionName];
        }
    }
    
    _departmentLabel.text = departAndposition;
    [_imgHeader sd_setImageWithURL:[NSURL URLWithString:model.imgHeaderName] placeholderImage:[UIImage imageNamed:@"user_icon_default"]];
    
    NSString *imgName = @"";
    if (!model.isSelect) {
        imgName = @"accessory_message_normal";
    } else {
        imgName = @"multi_graph_select";
    }
    _imgSelect.image = [UIImage imageNamed:imgName];
}
- (void)setFrameForAllPhone {
    CGFloat vX = kScreen_Width - 320;
//    _imgHeader.frame = [CommonFuntion setViewFrameOffset:_imgHeader.frame byX:0 byY:0 ByWidth:0 byHeight:0];
    _nameLabel.frame = [CommonFuntion setViewFrameOffset:_nameLabel.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    _departmentLabel.frame = [CommonFuntion setViewFrameOffset:_departmentLabel.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    _imgSelect.frame = [CommonFuntion setViewFrameOffset:_imgSelect.frame byX:vX byY:0 ByWidth:0 byHeight:0];
}
@end
