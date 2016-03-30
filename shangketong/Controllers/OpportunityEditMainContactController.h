//
//  OpportunityEditMainContactController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/12/21.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OpportunityEditMainContactController : UIViewController

@property (strong, nonatomic) NSMutableArray *sourceArray;
@property (copy, nonatomic) void(^refreshBlock)(void);

@end
