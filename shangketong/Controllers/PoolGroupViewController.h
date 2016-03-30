//
//  PoolGroupViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/9/28.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PoolGroupViewController : UIViewController

@property (assign, nonatomic) NSInteger poolType;
@property (strong, nonatomic) NSNumber *groupId;
@property (copy, nonatomic) NSString *bottomString;
@property (copy, nonatomic) void(^refreshBlock)(void);
@end
