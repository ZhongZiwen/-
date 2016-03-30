//
//  PlanSearchTypeCell.m
//  DemoMapViewPOI
//
//  Created by sungoin-zjp on 15-5-13.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "PlanSearchTypeCell.h"
#import "CommonFuntion.h"

@implementation PlanSearchTypeCell

- (void)awakeFromNib {
    // Initialization code
    self.clipsToBounds = YES;
    self.selectionStyle = UITableViewCellSelectionStyleGray;
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectedBackgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
    self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0];
    
    self.imgIcon.contentMode = UIViewContentModeScaleAspectFill;
    self.imgIcon.clipsToBounds = YES;
    self.imgIcon.layer.cornerRadius = self.imgIcon.frame.size.height/2;
    [self setCellFrame];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setCellFrame{
    self.imgIcon.frame = CGRectMake(20, 15, 10, 10);
    self.labelTitle.frame = CGRectMake(42, 10, kScreen_Width-100, 20);
    self.imgSelected.frame = CGRectMake(kScreen_Width-36, 15, 13, 9);
}


@end
