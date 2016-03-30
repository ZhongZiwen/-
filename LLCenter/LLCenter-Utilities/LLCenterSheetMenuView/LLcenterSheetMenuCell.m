//
//  SheetMenuCell.m
//  shangketong
//
//  Created by sungoin-zjp on 15-6-9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "LLcenterSheetMenuCell.h"
#import "LLCenterUtility.h"
#import "LLCenterSheetMenuModel.h"

@implementation LLcenterSheetMenuCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setCellDetails:(LLCenterSheetMenuModel *)item{
    self.labelName.text = item.title;
    self.labelName.frame = CGRectMake(15, 12, DEVICE_BOUNDS_WIDTH-90, 20);
    self.imgSelect.hidden = YES;
    self.accessoryType = UITableViewCellAccessoryNone;
    if ([item.selectedFlag isEqualToString:@"yes"]) {
//        self.imgSelect.hidden = NO;
        self.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    self.imgSelect.frame = CGRectMake(DEVICE_BOUNDS_WIDTH-33, 15, 20, 20);
}


@end
