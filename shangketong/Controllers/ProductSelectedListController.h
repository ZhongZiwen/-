//
//  ProductSelectedListController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/11/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "BaseViewController.h"

@class Product;

@interface ProductSelectedListController : BaseViewController

@property (strong, nonatomic) NSMutableArray *sourceArray;
@property (copy, nonatomic) void(^changeValueBlock)(Product*);
@end
