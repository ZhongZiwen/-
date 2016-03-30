//
//  TeamMemberOptionCell.m
//  shangketong
//
//  Created by sungoin-zjp on 15-7-8.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "TeamMemberOptionCell.h"

@implementation TeamMemberOptionCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setCellDetails:(NSDictionary *)item indexPath:(NSIndexPath *)indexPath{
    [self.btnDelete addTarget:self action:@selector(deleteMember:) forControlEvents:UIControlEventTouchUpInside];
    self.btnDelete.tag = indexPath.row;
    [self.btnPermission addTarget:self action:@selector(permissionMember:) forControlEvents:UIControlEventTouchUpInside];
    self.btnPermission.tag = indexPath.row;
}

///删除
-(void)deleteMember:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickTeamMemberDeleteEvent:)]) {
        [self.delegate clickTeamMemberDeleteEvent:btn.tag];
    }
}

///权限
-(void)permissionMember:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickTeamMemberPermissionEvent:)]) {
        [self.delegate clickTeamMemberPermissionEvent:btn.tag];
    }
}

@end
