//
//  CustomerListAddController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/11/2.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomerListAddController : UIViewController

@property (strong, nonatomic) NSNumber *activityId;
@property (copy, nonatomic) void(^refreshBlock)(void);
@end
