//
//  PhotoAssetModel.h
//  shangketong
//
//  Created by sungoin-zbs on 15/7/15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ALAsset;
@interface PhotoAssetModel : NSObject

@property (nonatomic, copy) NSString *groupName;            // 所在相簿名
@property (nonatomic, assign) NSInteger index;              // 索引
@property (nonatomic, assign) BOOL isSelected;              // 是否被选择
@property (nonatomic, strong) ALAsset *asset;

- (PhotoAssetModel*)initWithALAsset:(ALAsset*)alasset andGroupName:(NSString*)groupName andIndex:(NSInteger)index;
+ (PhotoAssetModel*)initWithALAsset:(ALAsset*)alasset andGroupName:(NSString*)groupName andIndex:(NSInteger)index;
@end
