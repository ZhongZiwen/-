//
//  SelectAreaTypeCell.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-27.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "SelectAreaTypeCell.h"
#import "LLCenterUtility.h"

@implementation SelectAreaTypeCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCellDetail:(NSDictionary *)item{
    self.labelTitle.text = [item safeObjectForKey:@"title"];
    self.labelInfos.text = [item safeObjectForKey:@"content"];
    
    NSString *checkboxImg = @"";
    if ([[item objectForKey:@"checked"] boolValue]) {
        checkboxImg = @"login_checkbox_filled.png";
    }else{
        checkboxImg = @"login_checkbox_empty.png";
    }
    [self.btnCheckBox setBackgroundImage:[UIImage imageNamed:checkboxImg] forState:UIControlStateNormal];
}

///type  1地区  2时间
-(void)setCellFrame:(NSInteger)type{
    self.imgArrow.frame = CGRectMake(DEVICE_BOUNDS_WIDTH-30, 15, 12, 20);
    self.labelInfos.frame = CGRectMake(125, 0, DEVICE_BOUNDS_WIDTH-125-35, 50);
    
}

@end
