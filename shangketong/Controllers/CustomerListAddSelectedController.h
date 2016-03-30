//
//  CustomerListAddSelectedController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/11/3.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomerListAddSelectedController : UIViewController

@property (strong, nonatomic) NSMutableArray *sourceArray;
@property (copy, nonatomic) void(^refleshBlock)(id);
@end
