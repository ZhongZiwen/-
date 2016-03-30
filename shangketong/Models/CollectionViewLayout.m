//
//  CollectionViewLayout.m
//  shangketong
//
//  Created by sungoin-zbs on 15/9/11.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "CollectionViewLayout.h"

@implementation CollectionViewLayout

// 决定cell怎么布局
- (NSArray*)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSMutableArray *array = [NSMutableArray array];
    
    NSUInteger count = [self.collectionView numberOfItemsInSection:0];
    
    for (int i = 0; i < count; i ++) {
        // 创建i位置cell对应的indexPath
        NSIndexPath *path = [NSIndexPath indexPathForItem:i inSection:0];
        
        // 创建i位置cell对应的布局属性
        UICollectionViewLayoutAttributes *attrs = [self layoutAttributesForItemAtIndexPath:path];
        
        // 添加布局属性
        [array addObject:attrs];
    }
    
    return array;
}

#define kSpaceWidth 10
#define kWidth (kScreen_Width - 6 * kSpaceWidth)/5.0
// 返回indexPath位置cell的布局属性
- (UICollectionViewLayoutAttributes*)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attrs.frame = CGRectMake(kSpaceWidth + (kWidth + kSpaceWidth) * (indexPath.item % 5), 20 + (kWidth + 30) * (indexPath.item / 5), kWidth, kWidth + 20);
    
    return attrs;
}

@end
