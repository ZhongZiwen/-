//
//  PlanSearchSwitherTableViewCell.m
//  DemoMapViewPOI
//
//  Created by sungoin-zjp on 15-5-13.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "PlanSearchSwitherTableViewCell.h"
#import "CommonFuntion.h"

@implementation PlanSearchSwitherTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.clipsToBounds = YES;
    self.selectionStyle = UITableViewCellSelectionStyleGray;
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectedBackgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
    self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0];
    [self setCellFrame];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCellFrame{
    self.labelTitle.frame = CGRectMake(20, 10, kScreen_Width-150, 20);
    self.switchBtn.frame = CGRectMake(kScreen_Width-66, 4, 51, 31);
}

@end
