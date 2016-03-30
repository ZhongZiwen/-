//
//  TeamMemberOptionCell.h
//  shangketong
//
//  Created by sungoin-zjp on 15-7-8.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TeamMemberPermOrDeleDelegate;

@interface TeamMemberOptionCell : UITableViewCell

@property (assign, nonatomic) id <TeamMemberPermOrDeleDelegate>delegate;

@property (strong, nonatomic) IBOutlet UIButton *btnPermission;
@property (strong, nonatomic) IBOutlet UIButton *btnDelete;

-(void)setCellDetails:(NSDictionary *)item indexPath:(NSIndexPath *)indexPath;

@end


@protocol TeamMemberPermOrDeleDelegate<NSObject>
@required
/// 团队删除成员事件
- (void)clickTeamMemberDeleteEvent:(NSInteger)index;

/// 团队权限更改成员事件
- (void)clickTeamMemberPermissionEvent:(NSInteger)index;
@end
