//
//  InfoCollectionCell.h
//  shangketong
//
//  Created by 蒋 on 16/2/17.
//  Copyright (c) 2016年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoCollectionCell : UICollectionViewCell
//1
@property (weak, nonatomic) IBOutlet UILabel *topicLabel;  //主题
@property (weak, nonatomic) IBOutlet UILabel *topicNameLabel; //未命名

//2
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;  //显示群昵称
@property (weak, nonatomic) IBOutlet UISwitch *showSwitch;

//3
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

- (IBAction)showContactNameAction:(UISwitch *)sender;

- (void)setFrameForAllPhone;
@end
