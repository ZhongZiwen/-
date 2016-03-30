//
//  CommonDetailsCellC.m
//  shangketong
//
//  Created by sungoin-zjp on 15-8-25.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "CommonDetailsCellC.h"

@implementation CommonDetailsCellC

- (void)awakeFromNib {
    // Initialization code
    self.labelTitle.frame = CGRectMake(15, 5, kScreen_Width-50, 20);
    self.btnIcon.frame = CGRectMake(15, 27, 30, 30);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


///填充详情
-(void)setCellDetails:(NSDictionary *)item indexPath:(NSIndexPath *)index{
    
    ///头像按钮点击事件
    self.btnIcon.tag = index.row;
    [self.btnIcon addTarget:self action:@selector(iconEvent:) forControlEvents:UIControlEventTouchUpInside];
}


-(void)iconEvent:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (self.IconEventBlock) {
        self.IconEventBlock(btn.tag);
    }
}



@end
