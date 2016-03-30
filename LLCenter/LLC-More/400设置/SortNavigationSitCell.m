//
//  SortNavigationSitCell.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-27.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SortNavigationSitCell.h"

@implementation SortNavigationSitCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCellDetails:(NSDictionary *)item{
    /*
     CALLORDER = 232538400;
     COMPANYID = "5a198602-a925-4a2c-a4fa-cd2aa4b63a20";
     LSH = 232538300;
     NUM = 1;
     SITID = "896a2b42-a9a7-49b5-8837-84a0b498cd1f";
     SITNAME = "\U738b\U8bdb\U9b54";
     SITNO = 2003;
     SITPHONE = 13918374623;
     USERID = "75c6507a-0682-45e5-af9c-c1ca87cc0189";
     WAITDURATION = 22;
     */
    NSString *sitName = @"";
    if ([item objectForKey:@"SITNAME"]) {
        sitName = [item safeObjectForKey:@"SITNAME"];
    }
    
    NSString *sitNo = @"";
    if ([item objectForKey:@"SITNO"]) {
        sitNo = [item safeObjectForKey:@"SITNO"];
    }
    
    self.labelNo.text = sitNo;
    self.labelTitle.text = sitName;
}

@end
