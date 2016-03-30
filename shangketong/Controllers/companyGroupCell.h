//
//  companyGroupCell.h
//  shangketong
//
//  Created by 蒋 on 15/10/16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CompanyGroupModel;

@interface companyGroupCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *groupName;
@property (weak, nonatomic) IBOutlet UIImageView *groupIcon;

- (void)setFrameAllPhone;
- (void)configWithModel:(CompanyGroupModel *)model;
@end
