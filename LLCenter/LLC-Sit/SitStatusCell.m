//
//  SitStatusCell.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-12.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "SitStatusCell.h"
#import "LLCenterUtility.h"

@implementation SitStatusCell

- (void)awakeFromNib {
    // Initialization code
    [self setCellFrame];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}


///设置详情
-(void)setCellDetails:(NSDictionary *)item{
    NSString *sitName = @"";
    if ([item objectForKey:@"sitName"]) {
        sitName = [item safeObjectForKey:@"sitName"];
    }
    ///最多显示8个，多出部门用...表示
    if (sitName.length>6) {
        sitName = [NSString stringWithFormat:@"%@...",[sitName substringToIndex:6]];
    }
    
    self.labelSitName.text = sitName;
    self.labelSitNo.text = [NSString stringWithFormat:@"工号:%@",[item safeObjectForKey:@"sitNo"]];
    NSInteger status = [[item safeObjectForKey:@"sitStatus"] integerValue];
    self.imgStatus.image = [UIImage imageNamed:[self getStatusImgByTag:status]];
    self.imgStatus.hidden = NO;
    
    
    [self.btnDetailsAcc addTarget:self action:@selector(gotoDetails:) forControlEvents:UIControlEventTouchUpInside];
}


///详情页面
- (void)gotoDetails:(id)sender {
    
    if (self.GotoDetailsBlock) {
        self.GotoDetailsBlock();
    }
}

-(NSString *)getStatusImgByTag:(NSInteger)tag{
    ///空闲 =1
    ///忙碌 =3
    ///电话接起=5
    ///不登录空闲7
    ///不接听=9
    NSString *imgName = @"icon_sit_status_gray.png";
    switch (tag) {
        case 1:
            imgName = @"icon_sit_status_green.png";
            break;
        case 3:
            imgName = @"icon_sit_status_red.png";
            break;
        case 5:
            imgName = @"icon_sit_status_red_lock.png";
            break;
        case 7:
            imgName = @"icon_sit_status_green_lock.png";
            break;
        case 9:
            imgName = @"icon_sit_status_gray.png";
            break;
            
        default:
            break;
    }
    NSLog(@"imgName:%@",imgName);
    return imgName;
}


-(void)setCellFrame{
    self.btnDetailsAcc.frame = CGRectMake(DEVICE_BOUNDS_WIDTH-33, 15, 20, 20);
    self.imgStatus.frame = CGRectMake(DEVICE_BOUNDS_WIDTH-85, 15, 20, 20);
}


@end
