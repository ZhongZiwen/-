//
//  ChatContactDetalsCell.h
//  shangketong
//  联系人cell
//  Created by 蒋 on 15/8/31.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ContactModel;

@interface ChatContactDetalsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgHeader;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *departmentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imgSelect;

- (void)configWithModel:(ContactModel *)model;
- (void)setFrameForAllPhone;
@end
