//
//  DetailStaffCCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/11.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "DetailStaffCCell.h"
#import "DetailStaffModel.h"

@interface DetailStaffCCell ()

@property (strong, nonatomic) UIImageView *imgView;
@property (strong, nonatomic) UIImageView *imageView_level;
@end

@implementation DetailStaffCCell

- (void)configWithModel:(DetailStaffModel *)item {
    
    if (!self.imgView) {
        self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        self.imgView.contentMode = UIViewContentModeScaleAspectFill;
        self.imgView.clipsToBounds = YES;
        [self.contentView addSubview:self.imgView];
    }
    
    if (!self.imageView_level) {
        UIImage *image = [UIImage imageNamed:@"member_owner"];
        self.imageView_level = [[UIImageView alloc] initWithImage:image];
        [self.imageView_level setWidth:image.size.width];
        [self.imageView_level setHeight:image.size.height];
        [self.imageView_level setCenterX:CGRectGetMaxX(_imgView.frame)];
        [self.imageView_level setCenterY:CGRectGetMaxY(_imgView.frame)];
        [self.contentView addSubview:self.imageView_level];
    }
    
    [_imgView sd_setImageWithURL:[NSURL URLWithString:item.icon] placeholderImage:[UIImage imageNamed:@"user_icon_default"]];
    
    if ([item.staffLevel integerValue] == 3) {
        _imageView_level.hidden = YES;
    }else {
        _imageView_level.hidden = NO;
    }
}

@end
