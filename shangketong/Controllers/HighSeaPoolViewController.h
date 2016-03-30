//
//  ClueHighSeaPoolViewController.h
//  shangketong
//  线索公海池/客户公海池
//  Created by sungoin-zjp on 15-6-3.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HighSeaPoolViewController : UIViewController
@property(strong,nonatomic) UITableView *tableviewHighSeaPool;
@property(strong,nonatomic) NSMutableArray *arrayHighSeaPool;

///公海池类型  线索公海池/客户公海池
@property(strong,nonatomic) NSString *typeOfPool;

@end
