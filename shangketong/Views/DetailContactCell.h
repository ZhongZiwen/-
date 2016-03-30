//
//  DetailContactCell.h
//  shangketong
//  ///团队成员
//  Created by sungoin-zjp on 15-6-9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TeamMember;

@protocol TeamMemberClickDelegate;
@interface DetailContactCell : UITableViewCell
@property (assign, nonatomic) id <TeamMemberClickDelegate>delegate;
@property (strong, nonatomic) IBOutlet UIButton *btnContact;
@property (strong, nonatomic) IBOutlet UIImageView *imgOwner;

-(void)setCellConetnt:(TeamMember *)item;

@end


@protocol TeamMemberClickDelegate<NSObject>
@required
///点击团队成员事件
- (void)clickTeamMemberEvent;
@end