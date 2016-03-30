//
//  SaleStageViewController.h
//  shangketong
//  销售阶段
//  Created by sungoin-zjp on 15-7-9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SaleStageViewController : UIViewController
@property(strong,nonatomic) UITableView *tableviewStages;
@property(strong,nonatomic) NSArray *arrayLostReasons;
@property(strong,nonatomic) NSArray *arrayOldStages;
@property (nonatomic, assign) long long stageId;
@end
