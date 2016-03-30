//
//  CustomerListStatusController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/11/3.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomerListStatusController : UIViewController

@property (strong, nonatomic) NSMutableArray *sourceArray;
@property (strong, nonatomic) NSMutableDictionary *params;
@property (copy, nonatomic) void(^refreshBlock)(void);
@end
