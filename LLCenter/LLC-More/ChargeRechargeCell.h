//
//  SelectTimeTypeCell.h
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-12-09.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChargeRechargeCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imgLine;

@property (strong, nonatomic) IBOutlet UIImageView *imgLineBottom;

@property (strong, nonatomic) IBOutlet UIImageView *imgPoint;
@property (strong, nonatomic) IBOutlet UILabel *labelDate;
@property (strong, nonatomic) IBOutlet UILabel *labelAmt;

@property (strong, nonatomic) IBOutlet UIImageView *imgBg;



-(void)setCellDetails:(NSDictionary *)item;

@end
