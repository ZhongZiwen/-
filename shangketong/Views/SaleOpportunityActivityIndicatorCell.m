//
//  SaleOpportunityActivityIndicatorCell.m
//  shangketong
//
//  Created by sungoin-zjp on 15-6-25.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SaleOpportunityActivityIndicatorCell.h"

@implementation SaleOpportunityActivityIndicatorCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

-(void)setCellFrame{
    self.actIndicator.frame = CGRectMake((kScreen_Width-20)/2, 20, 20, 20);
    //设置 风格;
    self.actIndicator.activityIndicatorViewStyle=UIActivityIndicatorViewStyleGray;
    //设置活动指示器的颜色
    self.actIndicator.color=[UIColor grayColor];
    //hidesWhenStopped默认为YES，会隐藏活动指示器。要改为NO
    self.actIndicator.hidesWhenStopped=NO;
    //启动
    [self.actIndicator startAnimating];
}

@end
