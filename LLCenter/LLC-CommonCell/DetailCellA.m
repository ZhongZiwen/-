//
//  DetailCellA.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-14.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "DetailCellA.h"
#import "LLCenterUtility.h"
#import "EditItemModel.h"

@implementation DetailCellA

- (void)awakeFromNib {
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    [self setCellFrame];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCellDetail:(EditItemModel *)model{
    self.labelLeft.text = model.title;
    self.lableRight.text = model.content;
}


-(void)setCellFrame{
    NSInteger width = 0;
    ///分辨率320
    if (DEVICE_IPHONE_WIDTH_320) {
        width = 0;
        self.labelLeft.font = [UIFont systemFontOfSize:14.0];
        self.lableRight.font = [UIFont systemFontOfSize:14.0];
    }else{
        width = 10;
        self.labelLeft.font = [UIFont systemFontOfSize:15.0];
        self.lableRight.font = [UIFont systemFontOfSize:15.0];
    }
    
    NSInteger width9 = 5;
    if (isIOS9) {
        width9 = 0;
    }
    
    self.labelLeft.frame = CGRectMake(10, 0, (DEVICE_BOUNDS_WIDTH-20-width9-width)/2, 50);
    self.lableRight.frame = CGRectMake(self.labelLeft.frame.origin.x+self.labelLeft.frame.size.width+width9+width/2, 0, (DEVICE_BOUNDS_WIDTH-20-width9-width)/2, 50);
}

@end
