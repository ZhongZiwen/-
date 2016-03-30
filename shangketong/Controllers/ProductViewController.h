//
//  ProductViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/4/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "BaseViewController.h"

@interface ProductViewController : BaseViewController

@property (strong, nonatomic) NSNumber *parentId;
@property (strong, nonatomic) NSMutableArray *selectedArray;
@property (assign, nonatomic) BOOL isAdd;

@property (copy, nonatomic) void(^refreshBlock)(void);
@property (copy, nonatomic) void(^selectedBlock)(void);
@end
