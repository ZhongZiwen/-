//
//  SaleStagesCell.m
//  shangketong
//
//  Created by sungoin-zjp on 15-7-9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SaleStagesCell.h"
#import "CommonFuntion.h"

@implementation SaleStagesCell

- (void)awakeFromNib {
    // Initialization code
    self.imgLineV.image = [CommonFuntion createImageWithColor:[UIColor colorWithRed:239.0f/255 green:239.0f/255 blue:239.0f/255 alpha:1.0f]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCellDetails:(NSDictionary *)item indexPath:(NSIndexPath *)indexPath andIsCanChecked:(BOOL)isCanChecked{
    self.labelName.frame = CGRectMake(60, 15, kScreen_Width-90, 20);
    ///stageName
    NSString *activityName = @"";
    if ([item objectForKey:@"activityName"]) {
        activityName = [item safeObjectForKey:@"activityName"];
    }
    
    NSString *percent = @"";
    if ([item objectForKey:@"percent"]) {
        percent = [item safeObjectForKey:@"percent"] ;
    }
    
    NSString *name_percent = [NSString stringWithFormat:@"%@(%@%%)",activityName,percent];
    self.labelName.text = name_percent;
    
    /// 1选中 0未选中
    NSString *checked = @"0";
    if ([item objectForKey:@"checked"]) {
        checked = [item safeObjectForKey:@"checked"] ;
    }
    
    if ([checked isEqualToString:@"1"]) {
        self.imgCheck.image = [UIImage imageNamed:@"btn_check_on.png"];
    }else{
        self.imgCheck.image = [UIImage imageNamed:@"btn_check_off.png"];
    }
    
    ///可选择
    if (isCanChecked) {
        
    }else{
    }
}

@end
