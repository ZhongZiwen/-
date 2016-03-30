//
//  TeamMemberManageCell.m
//  shangketong
//
//  Created by sungoin-zjp on 15-7-7.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "TeamMemberManageCell.h"
#import "UIImageView+WebCache.h"
#import "CommonConstant.h"

@implementation TeamMemberManageCell

- (void)awakeFromNib {
    self.imgIcon.contentMode = UIViewContentModeScaleAspectFill;
    self.imgIcon.clipsToBounds = YES;
    self.imgIcon.layer.cornerRadius = 3;
    
    self.imgOwnIcon.contentMode = UIViewContentModeScaleAspectFill;
    self.imgOwnIcon.clipsToBounds = YES;
//    self.imgOwnIcon.layer.cornerRadius = 3;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

///设置详情信息
-(void)setCellDetails:(NSDictionary *)item indexPath:(NSIndexPath *)indexPath{
//    [self addClickEvent:indexPath.section];
    self.imgLine.frame = CGRectMake(0, 59, kScreen_Width, 1);
    self.btnDetails.frame = CGRectMake(0, 0, kScreen_Width-70, 60);
    self.btnDetails.hidden = YES;
    ///头像
    NSString *iconUrl = @"";
    if ([item objectForKey:@"icon"]) {
        iconUrl = [item safeObjectForKey:@"icon"];
    }
    [self.imgIcon sd_setImageWithURL:[NSURL URLWithString:iconUrl] placeholderImage:[UIImage imageNamed:PLACEHOLDER_CONTACT_ICON]];
    self.imgIcon.frame = CGRectMake(15, 10, 40, 40);
    self.imgOwnIcon.frame = CGRectMake(50, 40, 12, 12);
    
    ///姓名 
    NSString *name = @"";
    if ([item objectForKey:@"name"]) {
        name = [item safeObjectForKey:@"name"];
    }
    self.labelName.text = name;
    self.labelName.frame = CGRectMake(70, 20, 75, 20);
    
    
    self.labelTag.frame = CGRectMake(kScreen_Width-160, 20, 100, 20);
    self.imgOpen.frame = CGRectMake(kScreen_Width-35, 20, 20, 20);
    
    if (indexPath.section == 0) {
        self.imgOpen.hidden = YES;
    }else{
        self.imgOpen.hidden = NO;
    }
}

///添加点击事件
-(void)addClickEvent:(NSInteger)index{
    
    [self.btnDetails addTarget:self action:@selector(setCellBackgroupColor) forControlEvents:UIControlEventTouchDown];
    
    [self.btnDetails addTarget:self action:@selector(clearCellBackgroupColor) forControlEvents:UIControlEventTouchCancel];
    
    [self.btnDetails addTarget:self action:@selector(clearCellBackgroupColor) forControlEvents:UIControlEventTouchUpOutside];
    
    [self.btnDetails addTarget:self action:@selector(goDetailsViewEvent:) forControlEvents:UIControlEventTouchUpInside];
    self.btnDetails.tag = index;
    
}

///详情按钮
-(void)goDetailsViewEvent:(id)sender{
    self.backgroundColor = [UIColor clearColor];
    UIButton *btn = (UIButton *)sender;
    NSInteger tag = btn.tag;
    
}

-(void)setCellBackgroupColor{
//    NSLog(@"setCellBackgroupColor-->");
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
}

-(void)clearCellBackgroupColor{
//    NSLog(@"clearCellBackgroupColor-->");
    self.backgroundColor = [UIColor clearColor];
}

@end
