//
//  PhotoAssetLibraryViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/7/15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PhotoAssetManager.h"

@interface PhotoAssetLibraryViewController : UIViewController

@property (nonatomic, strong) PhotoAssetManager *assetManager;
@property (assign, nonatomic) NSInteger maxCount;
@property (nonatomic, copy) void(^confirmBtnClickedBlock)(NSArray *imagesArray);

// 更新数据和ui
- (void)updateDataSource;

// 拍照的时候，自动选择拍照图片
- (void)autoAddCameraPhoto;
@end
