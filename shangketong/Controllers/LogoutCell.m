//
//  LogoutCell.m
//  shangketong
//
//  Created by sungoin-zjp on 15-7-15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "LogoutCell.h"

@implementation LogoutCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCellDetails:(NSString *)title{
    self.labelTitle.frame = CGRectMake(0, 0, kScreen_Width, 45);
    self.labelTitle.text = title;
}

@end
