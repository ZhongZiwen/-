//
//  ProductListViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/11/23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "BaseViewController.h"

@interface ProductListViewController : BaseViewController

@property (copy, nonatomic) void(^refreshBlock)(void);
@end
