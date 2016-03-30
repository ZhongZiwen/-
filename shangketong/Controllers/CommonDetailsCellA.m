//
//  CommonDetailsCellA.m
//  shangketong
//
//  Created by sungoin-zjp on 15-8-25.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "CommonDetailsCellA.h"

@implementation CommonDetailsCellA

- (void)awakeFromNib {
    // Initialization code
    self.labelTitle.frame = CGRectMake(15, 5, kScreen_Width-40, 20);
    self.labelContent.frame = CGRectMake(15, 35, kScreen_Width-40, 20);
    self.imgArrow.frame = CGRectMake(kScreen_Width-20-7, 24, 7, 12);
    self.labelTitle.textColor = LIGHT_BLUE_COLOR;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

///填充详情
-(void)setCellDetails:(NSDictionary *)item{
    
    NSString *title = @"";
    if ([item objectForKey:@"name"]) {
        title = [item safeObjectForKey:@"name"];
    }
    self.labelTitle.text = title;
    
    NSString *content = @"";
    if ([item objectForKey:@""]) {
        content = [item safeObjectForKey:@""];
    }
    
    if ([content isEqualToString:@""]) {
        self.labelContent.textColor = [UIColor lightGrayColor];
        content = @"未填写";
    }else{
        self.labelContent.textColor = [UIColor blackColor];
    }
    self.labelContent.text = content;
    
    
    ///判断箭头是否显示
    
}

@end
