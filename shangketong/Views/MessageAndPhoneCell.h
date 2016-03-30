//
//  messageAndPhoneCell.h
//  shangketong
//
//  Created by 蒋 on 15/7/1.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageAndPhoneCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UIButton *smsBtn;
@property (weak, nonatomic) IBOutlet UIButton *callBtn;

@end
