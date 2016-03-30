//
//  SalesLeadsCell.m
//  shangketong
//
//  Created by 蒋 on 15/9/23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SalesLeadsCell.h"
#import "CommonFuntion.h"
@implementation SalesLeadsCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)initWithDictionary:(NSDictionary *)dict {
    _nameLabel.text = [dict safeObjectForKey:@"name"];
    _companyLabel.text = [dict safeObjectForKey:@"companyName"];
    _timeLabel.text = [dict safeObjectForKey:@"mobile"];
}
- (void)setFrameForAllPhones {
    NSInteger Vx = kScreen_Width - 320;
    _nameLabel.frame = [CommonFuntion setViewFrameOffset:_nameLabel.frame byX:0 byY:0 ByWidth:Vx byHeight:0];
    _companyLabel.frame = [CommonFuntion setViewFrameOffset:_companyLabel.frame byX:0 byY:0 ByWidth:Vx byHeight:0];
    _timeLabel.frame = [CommonFuntion setViewFrameOffset:_timeLabel.frame byX:0 byY:0 ByWidth:Vx byHeight:0];
}
@end
