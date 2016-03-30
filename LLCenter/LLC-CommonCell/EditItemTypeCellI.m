//
//  EditItemTypeCellI.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-19.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "EditItemTypeCellI.h"
#import "EditItemModel.h"
#import "LLCenterUtility.h"

@implementation EditItemTypeCellI

- (void)awakeFromNib {
    // Initialization code
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)switchDefaultItem:(id)sender {
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isButtonOn = [switchButton isOn];
    NSString *isOnStatus = @"0";
    if (isButtonOn) {
        isOnStatus = @"1";
    }else {
        isOnStatus = @"0";
    }
    if (self.SwitchDefaultBlock) {
        self.SwitchDefaultBlock(isOnStatus);
    }
}

-(void)setCellDetail:(EditItemModel *)model{
    
    self.labelTitle.text = model.title;
    
    ///0未选择  1选中
    if ([model.content isEqualToString:@"1"]) {
        [self.switchDefault setOn:YES];
    }else{
        [self.switchDefault setOn:NO];
    }
    
    self.switchDefault.frame = CGRectMake(DEVICE_BOUNDS_WIDTH-51-10, 9, 51, 31);
}

@end
