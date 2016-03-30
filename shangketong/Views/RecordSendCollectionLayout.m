//
//  RecordSendCollectionLayout.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/27.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "RecordSendCollectionLayout.h"

@implementation RecordSendCollectionLayout

- (NSArray*)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *array = [NSMutableArray array];
    
    NSUInteger count = [self.collectionView numberOfItemsInSection:0];
    
    for (int i = 0; i < count; i ++) {
        NSIndexPath *path = [NSIndexPath indexPathForItem:i inSection:0];
        
        UICollectionViewLayoutAttributes *attrs = [self layoutAttributesForItemAtIndexPath:path];
        
        [array addObject:attrs];
    }
    return array;
}

#define kSpaceWidth 15
#define kWidth (kScreen_Width - 2 * kSpaceWidth - 3 * 10) / 4.0
- (UICollectionViewLayoutAttributes*)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attrs.frame = CGRectMake(kSpaceWidth + (kWidth + 10) * (indexPath.item % 4), (kWidth + 10) * (indexPath.item / 4), kWidth, kWidth);
    return attrs;
}
@end
