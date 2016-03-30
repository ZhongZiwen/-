//
//  PlanSearchSwitherTableViewCell.h
//  DemoMapViewPOI
//   开关
//  Created by sungoin-zjp on 15-5-13.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlanSearchSwitherTableViewCell : UITableViewCell


@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UISwitch *switchBtn;

-(void)setCellFrame;

@end
