//
//  ColumnMoreViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/9/22.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ColumnMoreViewController : UIViewController

@property (strong, nonatomic) NSMutableArray *sourceArray;
@property (copy, nonatomic) void(^confireBlock)(void);
@end
