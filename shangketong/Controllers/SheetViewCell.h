//
//  SheetViewCell.h
//  shangketong
//
//  Created by 蒋 on 16/1/20.
//  Copyright (c) 2016年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SheetViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UIButton *messageBtn;
@property (weak, nonatomic) IBOutlet UIButton *phoneBtn;

@end
