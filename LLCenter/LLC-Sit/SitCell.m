//
//  SitCell.m
//  
//
//  Created by sungoin-zjp on 16/1/5.
//
//

#import "SitCell.h"

@implementation SitCell

- (void)awakeFromNib {
    // Initialization code
    
    self.labelName.frame = CGRectMake(15, 10, 120, 20);
    self.labelNo.frame = CGRectMake(15, 30, 120, 20);
    self.lablePhone.frame = CGRectMake(145, 20, 120, 20);
    self.imgIcon.frame = CGRectMake(kScreen_Width-35, 20, 20, 20);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


///填充详情
-(void)setCellDetail:(NSDictionary *)item{
    
    /*
     {
     sitId = "b51c61a7-48d6-4dcc-b6af-a9884a13f9e3";
     sitName = test1;
     sitNo = 2001;
     sitStatus = 7;
     }
     */
    
    NSString *sitName = @"";
    if ([item objectForKey:@"sitName"]) {
        sitName = [item safeObjectForKey:@"sitName"];
    }
    ///最多显示6个，多出部门用...表示
    if (sitName.length>6) {
        sitName = [NSString stringWithFormat:@"%@...",[sitName substringToIndex:6]];
    }
    
    NSString *sitNo = [item safeObjectForKey:@"sitNo"];
    NSString *phone = [item safeObjectForKey:@"sitPhone"];
    
    
    self.labelName.text = sitName;
    self.labelNo.text = sitNo;
    self.lablePhone.text = phone;
}


@end
