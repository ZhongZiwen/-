//
//  SitStatusCell.h
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-12.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SitStatusCell : UITableViewCell


@property (strong, nonatomic) IBOutlet UILabel *labelSitName;
@property (strong, nonatomic) IBOutlet UILabel *labelSitNo;
@property (strong, nonatomic) IBOutlet UIImageView *imgStatus;
@property (strong, nonatomic) IBOutlet UIButton *btnDetailsAcc;



///设置详情
-(void)setCellDetails:(NSDictionary *)item;

///跳转到详情页面
@property (nonatomic, copy) void (^GotoDetailsBlock)(void);

@end
