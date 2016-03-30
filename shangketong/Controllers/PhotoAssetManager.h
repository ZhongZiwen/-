//
//  PhotoAssetManager.h
//  shangketong
//
//  Created by sungoin-zbs on 15/7/15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AssetsLibrary/AssetsLibrary.h>

@class PhotoAssetModel;

#define kGroupLabelText     @"groupLabelText"
#define kGroupPhotoCounts   @"groupPhotoCounts"
#define kGroupURL           @"groupURL"
#define kGroupPosterImage   @"groupPosterImage"

@interface PhotoAssetManager : NSObject

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *assetsGroupArray;     // 相簿数组
@property (nonatomic, strong) NSMutableArray *groupPhotoaArray;     // 某相簿中照片数组
@property (nonatomic, strong) NSMutableArray *selectedArray;        // 选中照片数组

/**
 * 获取照片库的所有相册
 */
- (void)getALAssetsGroupAllComplete:(void(^)())complete;

/**
 * 根据URL检索某相簿的所有资源
 */
- (void)retrieveAssetGroupByURL:(NSURL*)url andGroupName:(NSString*)groupName complete:(void(^)())complete;

/**
 * 从选中数组中删除对应的元素
 */
- (void)deleteObjFromSelectedArrayWith:(PhotoAssetModel*)model;

/**
 * 删除选中数组中的照片时，同时将该对象从相簿中删除
 */
- (void)deleteObjFromGroupPhotoArrayWith:(PhotoAssetModel*)model;

- (void)selecteCameraPhoto;
@end
