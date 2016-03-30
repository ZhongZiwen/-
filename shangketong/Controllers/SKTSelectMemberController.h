//
//  SKTSelectMemberController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/8/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SKTSelectMemberController : UIViewController

@property (strong, nonatomic) NSMutableArray *selectedArray;
@property (nonatomic, copy) void(^valueBlock) (NSArray *valueArray);
@end
