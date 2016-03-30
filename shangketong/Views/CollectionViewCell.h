//
//  CollectionViewCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/9/11.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AddressBook, FilterValue;

@interface CollectionViewCell : UICollectionViewCell

- (void)configWithAddressBook:(AddressBook*)item isDelete:(BOOL)isDelete;
- (void)configWithFilterValue:(FilterValue*)item isDelete:(BOOL)isDelete;
- (void)configWithImageStr:(NSString*)imageStr;
@end
