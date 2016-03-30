//
//  SheetViewCell.m
//  shangketong
//
//  Created by 蒋 on 16/1/20.
//  Copyright (c) 2016年 sungoin. All rights reserved.
//

#import "SheetViewCell.h"

@implementation SheetViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)messageOrPhoneBtn:(UIButton *)sender {
    if (sender.tag == 100) {
        NSLog(@"发短信");
    } else {
        NSLog(@"打电话");
    }
}

@end
