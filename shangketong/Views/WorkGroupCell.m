//
//  WorkGroupCell.m
//  shangketong
//
//  Created by sungoin-zjp on 15-5-21.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "WorkGroupCell.h"

@implementation WorkGroupCell

- (void)awakeFromNib {
    // Initialization code
//    self.clipsToBounds = YES;
//    self.selectionStyle = UITableViewCellSelectionStyleGray;
//    self.accessoryType = UITableViewCellAccessoryNone;
//    self.selectedBackgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
//    self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor whiteColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
