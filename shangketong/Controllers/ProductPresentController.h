//
//  ProductPresentController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/11/23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Product;

@interface ProductPresentController : UIViewController

@property (strong, nonatomic) Product *item;
@property (copy, nonatomic) void(^refreshBlock)(void);
@end
