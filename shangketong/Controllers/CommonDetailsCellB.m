//
//  CommonDetailsCellB.m
//  shangketong
//
//  Created by sungoin-zjp on 15-8-25.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "CommonDetailsCellB.h"

@implementation CommonDetailsCellB

- (void)awakeFromNib {
    // Initialization code
    self.btnRight.frame = CGRectMake(kScreen_Width-60, 0, 60, 60);
    self.imgLine.frame = CGRectMake(kScreen_Width-61, 0, 1, 60);
    self.labelTitle.frame = CGRectMake(15, 5, kScreen_Width-100, 20);
    self.labelContent.frame = CGRectMake(15, 35, kScreen_Width-100, 20);
    self.btnLeft.frame = CGRectMake(0, 0, kScreen_Width-60, 60);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}


///填充详情
-(void)setCellDetails:(NSDictionary *)item indexPath:(NSIndexPath *)index{
    
    ///按钮点击事件
    ///传id  根据点击事件请求接口决定
    self.btnLeft.tag = index.row;
    [self.btnLeft addTarget:self action:@selector(leftEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.btnRight.tag = index.row;
    [self.btnRight addTarget:self action:@selector(rightEvent:) forControlEvents:UIControlEventTouchUpInside];
    
}


-(void)leftEvent:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (self.DetailsLeftEventBlock) {
        self.DetailsLeftEventBlock(btn.tag);
    }
}

-(void)rightEvent:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (self.DetailsRightEventBlock) {
        self.DetailsRightEventBlock(btn.tag);
    }
}

@end
