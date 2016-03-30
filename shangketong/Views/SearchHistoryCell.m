//
//  SearchHistoryCell.m
//  shangketong
//
//  Created by sungoin-zjp on 15-6-23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SearchHistoryCell.h"

@implementation SearchHistoryCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


///设置cell详情  ---key:searchStr
-(void)setCellDetails:(NSDictionary *)item{
    NSString *searchStr = @"";
    if ([item objectForKey:@"name"]) {
        searchStr = [item safeObjectForKey:@"name"];
    }
    self.labelSearchStr.text = searchStr;
}


-(void)setCellFrame{
    self.labelSearchStr.frame = CGRectMake(15, 14, kScreen_Width-30, 20);
}

@end
