//
//  AddOrDeleteCell.h
//  shangketong
//  添加、删除联系人界面
//  Created by 蒋 on 15/9/16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddOrDeleteCell : UITableViewCell

//0
@property (weak, nonatomic) IBOutlet UILabel *topicLabel; //主题
@property (weak, nonatomic) IBOutlet UILabel *topicNameLabel; //主题内容
//1
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel; //群名称
@property (weak, nonatomic) IBOutlet UISwitch *showSwitch;
//2
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

- (IBAction)showContactNameAction:(UISwitch *)sender;
- (void)setFrameForAllPhone;
@end
