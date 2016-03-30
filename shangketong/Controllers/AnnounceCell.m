//
//  AnnounceCell.m
//  shangketong
//
//  Created by 蒋 on 15/9/29.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "AnnounceCell.h"
#import "CommonFuntion.h"
#import "AnnounceModel.h"
@implementation AnnounceCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)configWithModel:(AnnounceModel *)model {
    if ([CommonFuntion checkNullForValue:model.typeName]) {
        _titleLabel.text = [NSString stringWithFormat:@"【%@】%@", model.typeName,model.title];
    } else {
        _titleLabel.text = model.title;
    }
    
    if ([model.isHasRead isEqualToString:@"1"]) {
        _flagLabel.hidden = NO;
        _flagLabel.layer.masksToBounds = YES;
        _flagLabel.layer.cornerRadius = 5;
        _flagLabel.backgroundColor = [UIColor redColor];
    } else {
        _flagLabel.hidden = YES;
    }
    _detailsLabel.text = [NSString stringWithFormat:@"%@  %@  %@", model.createDate, model.deptName, model.createUserName];
}
- (void)setFrameAllPhone {
    NSInteger Vx = kScreen_Width - 320;
    _titleLabel.frame = [CommonFuntion setViewFrameOffset:_titleLabel.frame byX:0 byY:0 ByWidth:Vx byHeight:0 ];
    _detailsLabel.frame = [CommonFuntion setViewFrameOffset:_detailsLabel.frame byX:0 byY:0 ByWidth:Vx byHeight:0];
    _flagLabel.frame = [CommonFuntion setViewFrameOffset:_flagLabel.frame byX:Vx byY:0 ByWidth:0 byHeight:0 ];
}
@end
