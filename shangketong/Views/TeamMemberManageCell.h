//
//  TeamMemberManageCell.h
//  shangketong
//  团队成员管理-cell
//  Created by sungoin-zjp on 15-7-7.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TeamMemberManageCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imgIcon;
@property (strong, nonatomic) IBOutlet UIImageView *imgOwnIcon;
@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UILabel *labelTag;
@property (strong, nonatomic) IBOutlet UIImageView *imgOpen;
@property (strong, nonatomic) IBOutlet UIButton *btnDetails;


@property (strong, nonatomic) IBOutlet UIImageView *imgLine;


-(void)setCellDetails:(NSDictionary *)item indexPath:(NSIndexPath *)indexPath;

@end
