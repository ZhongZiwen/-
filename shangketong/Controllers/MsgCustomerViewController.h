//
//  MsgCustomerViewController.h
//  shangketong
//  群发短信时客户列表
//  Created by sungoin-zjp on 15-6-15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MsgCustomerViewController : UIViewController
@property(strong,nonatomic) UITableView *tableviewCustomer;
@property(strong,nonatomic) NSMutableArray *arrayCustomer;

///标记不同的from view    msgCustomer   addCustomer
@property(strong,nonatomic) NSString *typeViewFrom;
@property (nonatomic, copy) void(^BackCustomersBlock)(NSArray *array);

@end
