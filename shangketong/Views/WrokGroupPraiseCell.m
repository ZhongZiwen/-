//
//  WrokGroupPraiseCell.m
//  shangketong
//
//  Created by sungoin-zjp on 15-7-10.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//


#import "WrokGroupPraiseCell.h"
#import "UIButton+WebCache.h"
#import "CommonConstant.h"

@implementation WrokGroupPraiseCell

- (void)awakeFromNib {
    self.btnIcon.transform = CGAffineTransformMakeRotation(M_PI/2);
    self.btnIcon.layer.cornerRadius = 3;
    self.btnIcon.imageView.layer.cornerRadius = 3;
    
    self.btnIcon.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.btnIcon.imageView.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

///设置cell详情
-(void)setCellDetails:(NSDictionary *)item indexPath:(NSIndexPath *)indexPath{
    NSLog(@"praise setCellDetails ");
    NSString *icon = @"";
    ///头像
    if ([item objectForKey:@"icon"]) {
        icon = [item safeObjectForKey:@"icon"];
    }
    self.btnIcon.userInteractionEnabled = NO;
    ///第一个标志是赞的图标
    if (indexPath.row == 0) {
        [self.btnIcon setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
    }else{
        ///头像
        [self.btnIcon sd_setImageWithURL:[NSURL URLWithString:icon] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:PLACEHOLDER_CONTACT_ICON]];
    }
}

@end
