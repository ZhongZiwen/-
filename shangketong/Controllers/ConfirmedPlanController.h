//
//  ConfirmedPlanController.h
//  shangketong
//
//  Created by 蒋 on 15/8/14.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfirmedPlanController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableViewConfirmed;
@property (nonatomic, strong) NSArray *dataSoucerArrayOld;
@property (nonatomic, copy) void(^backDataSoucerBlock)(NSArray *array);
@end
