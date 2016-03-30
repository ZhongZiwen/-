//
//  PhotoAssetModel.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "PhotoAssetModel.h"

@implementation PhotoAssetModel

- (PhotoAssetModel*)initWithALAsset:(ALAsset *)alasset andGroupName:(NSString *)groupName andIndex:(NSInteger)index {
    self = [super init];
    if (self) {
        self.asset = alasset;
        self.groupName = groupName;
        self.isSelected = NO;
        self.index = index;
    }
    return self;
}

+ (PhotoAssetModel*)initWithALAsset:(ALAsset *)alasset andGroupName:(NSString *)groupName andIndex:(NSInteger)index {
    PhotoAssetModel *model = [[PhotoAssetModel alloc] initWithALAsset:alasset andGroupName:groupName andIndex:index];
    return model;
}
@end
