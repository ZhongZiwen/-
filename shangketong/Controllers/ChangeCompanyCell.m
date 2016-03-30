//
//  ChangeCompanyCell.m
//  shangketong
//
//  Created by sungoin-zjp on 15-7-15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ChangeCompanyCell.h"

@implementation ChangeCompanyCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setCellDetails:(NSDictionary *)item{
    self.imgCheck.frame = CGRectMake(kScreen_Width-23, 20, 13, 10);
    self.labelTitle.frame = CGRectMake(50, 15, kScreen_Width-90, 20);
    
    NSString *title = @"";
    if ([item objectForKey:@"name"]) {
        title = [item safeObjectForKey:@"name"];
    }
    self.labelTitle.text = title;
}

@end
