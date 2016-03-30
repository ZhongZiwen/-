//
//  CommonDetailsCellD.m
//  shangketong
//
//  Created by sungoin-zjp on 15-9-6.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "CommonDetailsCellD.h"

@implementation CommonDetailsCellD

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setCellDetails:(NSDictionary *)item{
    NSString *name = @"";
    if ([item safeObjectForKey:@"name"]) {
        name = [item safeObjectForKey:@"name"];
    }
    self.labelTitle.text = name;
}

@end
