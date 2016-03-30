//
//  ChatContactCell.h
//  shangketong
//  底部选择联系人cell
//  Created by 蒋 on 15/8/31.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactModel.h"

@interface ChatContactCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgIcon;

- (void)configWithModel:(ContactModel *)model;
@end
