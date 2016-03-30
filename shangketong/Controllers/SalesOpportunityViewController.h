//
//  SalesOpportunityViewController.h
//  shangketong
//  CRM - 销售机会
//  Created by sungoin-zjp on 15-6-19.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SalesOpportunityViewController : UIViewController
@property(strong,nonatomic) UITableView *tableviewSaleOpportunity;
@property(nonatomic,strong) NSMutableArray *arraySaleOpportunity;

@property (nonatomic, assign) NSInteger oldTag;
@property (nonatomic, assign) BOOL isOpen;
@property (nonatomic, assign) NSInteger selectedIndex;
@end
