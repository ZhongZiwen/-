//
//  CustomerManageViewController.h
//  lianluozhongxin
//  客户管理
//  Created by sungoin-zjp on 15-7-2.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomerManageViewController : AppsBaseViewController

@property(strong,nonatomic) UITableView *tableviewCustomer;
@property(strong,nonatomic) NSMutableArray *dataSource;
@property(strong,nonatomic) NSMutableArray *dataSourceShow;


//检查版本信息
- (void)getVersionDataFromServer ;

@end
