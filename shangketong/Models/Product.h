//
//  Product.h
//  shangketong
//
//  Created by sungoin-zbs on 15/11/20.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Product : NSObject<NSCopying>

// 产品
@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) NSNumber *type;       // 1产品目录  2产品
@property (strong, nonatomic) NSNumber *child;
@property (strong, nonatomic) NSNumber *price;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *icon;
@property (copy, nonatomic) NSString *unit;

// 销售机会产品清单
@property (strong, nonatomic) NSNumber *productId;  // 销售机会中产品列表用到，用于查看产品详情
@property (strong, nonatomic) NSNumber *standardPrice;  // 基本价格
@property (strong, nonatomic) NSNumber *unitPrice;      // 单价
@property (strong, nonatomic) NSNumber *discount;       // 折扣
@property (strong, nonatomic) NSNumber *totalPrivce;    // 折扣后的总价
@property (strong, nonatomic) NSNumber *number;         // 数量
@end