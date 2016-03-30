//
//  DetailContactCell.m
//  shangketong
//
//  Created by sungoin-zjp on 15-6-9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "DetailContactCell.h"
#import "UIButton+WebCache.h"
#import "CommonConstant.h"
#import "TeamMember.h"
@implementation DetailContactCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
    self.backgroundView = nil;
    
    self.btnContact.layer.cornerRadius = 3;
    self.btnContact.imageView.layer.cornerRadius = 3;
    // 倒置
    self.btnContact.transform = CGAffineTransformMakeRotation(M_PI/2);
    self.imgOwner.transform = CGAffineTransformMakeRotation(M_PI/2);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

///cell头像和ower图标
-(void)setCellConetnt:(TeamMember *)item{

    [self.btnContact sd_setImageWithURL:[NSURL URLWithString:item.m_icon] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:PLACEHOLDER_CONTACT_ICON]];
}


///团队成员管理页面
- (IBAction)gotoManagerView:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickTeamMemberEvent)]) {
        [self.delegate clickTeamMemberEvent];
    }
}



@end
