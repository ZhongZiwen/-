//
//  KnowledgeDepartmentCell.m
//  shangketong
//
//  Created by sungoin-zjp on 15-6-13.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "KnowledgeDepartmentCell.h"

@implementation KnowledgeDepartmentCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCellDetails:(NSDictionary *)item{
    self.labelName.frame = CGRectMake(60, 14, kScreen_Width-80, 20);
    
    NSString *name = @"";
    if ([item objectForKey:@"name"]) {
        name = [item safeObjectForKey:@"name"];
    }
    self.labelName.text = name;
}

-(void)setCellFrame{
    
}

@end
