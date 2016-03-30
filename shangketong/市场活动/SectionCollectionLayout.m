//
//  SectionCollectionLayout.m
//  
//
//  Created by 钟必胜 on 15/10/3.
//
//

#import "SectionCollectionLayout.h"

@implementation SectionCollectionLayout

- (NSArray*)layoutAttributesForElementsInRect:(CGRect)rect {
//    NSMutableArray* attributes = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
//    
//    //从第二个循环到最后一个
//    for(int i = 1; i < [attributes count]; ++i) {
//        //当前attributes
//        UICollectionViewLayoutAttributes *currentLayoutAttributes = attributes[i];
//        //上一个attributes
//        UICollectionViewLayoutAttributes *prevLayoutAttributes = attributes[i - 1];
//        //我们想设置的最大间距，可根据需要改
//        NSInteger maximumSpacing = 0;
//        //前一个cell的最右边
//        NSInteger origin = CGRectGetMaxX(prevLayoutAttributes.frame);
//        //如果当前一个cell的最右边加上我们想要的间距加上当前cell的宽度依然在contentSize中，我们改变当前cell的原点位置
//        //不加这个判断的后果是，UICollectionView只显示一行，原因是下面所有cell的x值都被加到第一行最后一个元素的后面了
//        if(origin + maximumSpacing + currentLayoutAttributes.frame.size.width < self.collectionViewContentSize.width) {
//            CGRect frame = currentLayoutAttributes.frame;
//            frame.origin.x = origin + maximumSpacing;
//            currentLayoutAttributes.frame = frame;
//        }
//    }
//    return attributes;
    
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
    attrs.frame = CGRectMake(kScreen_Width / 4 * indexPath.item, 0, kScreen_Width / 4, 64);
    
    return attrs;
}


@end
