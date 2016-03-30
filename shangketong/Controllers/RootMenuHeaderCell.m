//
//  RootMenuHeaderCell.m
//  shangketong
//
//  Created by sungoin-zjp on 15-12-19.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "RootMenuHeaderCell.h"
#import "UIImageView+WebCache.h"

@implementation RootMenuHeaderCell

- (void)awakeFromNib {
    // Initialization code
    self.imgIcon.contentMode = UIViewContentModeScaleAspectFill;
    self.imgIcon.clipsToBounds = YES;
    self.imgIcon.layer.cornerRadius = 6;
    self.imgArrow.hidden = YES;
    self.imgArrow.frame = CGRectMake(kScreen_Width-15-8, 33, 8, 13);
    self.imgIcon.frame = CGRectMake(15, 8, 64, 64);
    self.labelName.frame = CGRectMake(94, 17, kScreen_Width-130, 20);
    self.labelCompany.frame = CGRectMake(94, 43, kScreen_Width-130, 20);
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator; //显示最右边的箭头
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setCellDetails:(NSDictionary *)item{
    NSString *name = @"";
    NSString *company = @"";
    NSString *icon = @"";
    if(item){
        name = [item safeObjectForKey:@"name"];
        company = [item safeObjectForKey:@"companyName"];
        icon = [item safeObjectForKey:@"icon"];
    }
    
    [self.imgIcon sd_setImageWithURL:[NSURL URLWithString:icon] placeholderImage:[UIImage imageNamed:PLACEHOLDER_REVIEW_IMG]];
    self.labelName.text = name;
    self.labelCompany.text = company;
}



@end
