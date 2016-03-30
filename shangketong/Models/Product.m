//
//  Product.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/20.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "Product.h"

@implementation Product

- (instancetype)copyWithZone:(NSZone *)zone {
    // 实现自定义拷贝
    Product *product = [[self class] allocWithZone:zone];
    product.id = [_id copy];
    product.productId = [_productId copy];
    product.name = [_name copy];
    product.icon = [_icon copy];
    product.standardPrice = [_standardPrice copy];
    product.unitPrice = [_unitPrice copy];
    product.discount = [_discount copy];
    product.totalPrivce = [_totalPrivce copy];
    product.number = [_number copy];
    return product;
}
@end