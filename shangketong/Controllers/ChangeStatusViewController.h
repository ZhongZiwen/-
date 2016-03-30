//
//  ChangeStatusViewController.h
//  shangketong
//   活动、销售状态
//  Created by sungoin-zjp on 15-7-9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangeStatusViewController : UIViewController
@property(strong,nonatomic) UITableView *tableviewChangeStatus;
@property(strong,nonatomic) NSArray *arrayChangeStatus;
///状态类型 campaign  salelead
@property(strong,nonatomic) NSString *typeOfStatus;
///已选中的状态
@property(assign,nonatomic) NSInteger selectedIndex;


@property (nonatomic, copy) void (^notifyActivityStatusBlock)(NSString *value,NSInteger statusId);

@end
