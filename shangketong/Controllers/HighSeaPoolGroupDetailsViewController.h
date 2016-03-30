//
//  HighSeaPoolGroupDetailsViewController.h
//  shangketong
//  公海池 list
//  Created by sungoin-zjp on 15-6-3.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HighSeaPoolGroupDetailsViewController : UIViewController
@property(strong,nonatomic) UITableView *tableviewHighSeaPools;
@property(strong,nonatomic) NSMutableArray *arrayHighSeaPools;

///id
@property(strong,nonatomic)NSString *highSeaId;

///公海池类型  线索公海池/客户公海池
@property(strong,nonatomic)NSString *typeOfPool;

@end
