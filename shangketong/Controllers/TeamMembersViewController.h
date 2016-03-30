//
//  TeamMembersViewController.h
//  shangketong
//  团队成员
//  Created by sungoin-zjp on 15-7-7.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TeamMembersViewController : UIViewController

@property(strong,nonatomic) UITableView *tableviewTeamMembers;
@property(strong,nonatomic) NSArray *arrayTeamMembers;
@property(strong,nonatomic) NSArray *arrayOwerTeamMembers;
@property(strong,nonatomic) NSDictionary *permission;


///展开标记
@property (assign)BOOL isOpen;
@property (nonatomic,retain)NSIndexPath *selectIndex;

@end
