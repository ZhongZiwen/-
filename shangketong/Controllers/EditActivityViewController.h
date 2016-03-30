//
//  DetailInfoEditViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/8.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "XLFormBaseViewController.h"

@interface EditActivityViewController : XLFormBaseViewController

@property (strong, nonatomic) NSNumber *id;
@property (copy, nonatomic) NSString *requestPath;
@property (copy, nonatomic) void(^refreshBlock)(void);
@end
