//
//  FilterSelectedController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterSelectedController : UIViewController

@property (strong, nonatomic) NSMutableArray *selectedArray;
@property (strong, nonatomic) NSMutableArray *unSelectedArray;
@property (copy, nonatomic) void(^refreshBlock)(void);
@end
