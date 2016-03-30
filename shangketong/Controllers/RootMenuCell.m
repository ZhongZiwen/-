//
//  RootMenuCell.m
//  shangketong
//
//  Created by sungoin-zjp on 15-12-19.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "RootMenuCell.h"


@implementation RootMenuCell

- (void)awakeFromNib {
    // Initialization code
    self.imgArrow.hidden = YES;
    self.imgArrow.frame = CGRectMake(kScreen_Width-15-8, 16, 8, 13);
    self.imgRedCircle.frame = CGRectMake(kScreen_Width-15-8-15-20, 13, 20, 20);
    self.labelNum.frame = CGRectMake(kScreen_Width-15-8-15-20, 13, 20, 20);
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator; //显示最右边的箭头
    self.imgRedCircle.contentMode = UIViewContentModeScaleAspectFill;
    self.imgRedCircle.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

///@"image":@"menu_item_feed", @"title":@"工作圈",@"switch":@YES,@"type":@"groupA",@"eventIndex":@"1",@"unreadmsg",@""
-(void)setCellDetails:(RootMenuModel *)item withType:(NSInteger)type{
    
    self.imgIcon.image = [UIImage imageNamed:item.menu_image];
    self.labelTitle.text = item.menu_title;
    
    self.labelNum.hidden = YES;
    self.imgRedCircle.hidden = YES;
    self.imgNewMsg.hidden = YES;
//    NSLog(@"item.menu_unreadmsg:%@",item.menu_unreadmsg);
    
    /// OA
    if (type == 1) {
        ///工作圈
        if ([item.menu_tag integerValue] == 1) {
            if (appDelegateAccessor.moudle.icon_oa_workzone_newtrends && appDelegateAccessor.moudle.icon_oa_workzone_newtrends.length > 0) {
                self.imgRedCircle.frame = CGRectMake(kScreen_Width-15-8-15-30, 8, 30, 30);
                self.imgNewMsg.frame = CGRectMake(kScreen_Width-15-8-15, 2, 8, 8);
 
                [self.imgRedCircle sd_setImageWithURL:[NSURL URLWithString:appDelegateAccessor.moudle.icon_oa_workzone_newtrends] placeholderImage:[UIImage imageNamed:PLACEHOLDER_CONTACT_ICON]];
                self.imgRedCircle.hidden = NO;
                self.imgNewMsg.hidden = NO;
            }
        }else{
            self.imgRedCircle.frame = CGRectMake(kScreen_Width-15-8-15-20, 13, 20, 20);
            self.imgRedCircle.image = [UIImage imageNamed:@"badge_1.png"];
            if (item.menu_unreadmsg && ![item.menu_unreadmsg isEqualToString:@""] && [item.menu_unreadmsg integerValue] > 0) {
                self.labelNum.hidden = NO;
                self.imgRedCircle.hidden = NO;
                self.labelNum.text = item.menu_unreadmsg;
            }
        }
    }else{
//        self.imgRedCircle.frame = CGRectMake(kScreen_Width-15-8-15-20, 13, 20, 20);
//        self.imgRedCircle.image = [UIImage imageNamed:@"badge_1.png"];
        if (item.menu_unreadmsg && ![item.menu_unreadmsg isEqualToString:@""] && [item.menu_unreadmsg integerValue] > 0) {
            self.labelNum.hidden = NO;
            self.imgRedCircle.hidden = NO;
            self.labelNum.text = item.menu_unreadmsg;
        }
    }
    
    
}



@end
