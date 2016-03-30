//
//  CRMContactSearchViewController.h
//  shangketong
//  联系人搜索页面
//  Created by sungoin-zjp on 15-6-15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CRMContactSearchViewController : UIViewController
@property(strong,nonatomic) UITableView *tableviewContact;
@property(strong,nonatomic) NSMutableArray *arrayContact;

///最近联系人/联系人
@property(strong,nonatomic)NSString *typeContact;

@end
