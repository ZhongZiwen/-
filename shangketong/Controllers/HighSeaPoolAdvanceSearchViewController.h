//
//  HighSeaPoolAdvanceSearchViewController.h
//  shangketong
//  高级检索
//  Created by sungoin-zjp on 15-6-4.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HighSeaPoolAdvanceSearchViewController : UIViewController
@property(strong,nonatomic) UITableView *tableviewAdvanceSearch;
@property(strong,nonatomic) NSArray *arrayAdvanceSearch;

///选择的下标
@property(assign,nonatomic) NSInteger indexSelected;
@end
