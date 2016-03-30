//
//  PhotoBrowserViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/7/20.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, PhotoBrowserType) {
    PhotoBrowserTypeAll,        // 预览全部图片资源
    PhotoBrowserTypeSelected,   // 预览已选择的图片
    PhotoBrowserTypeDelete      // 预览已选择的图片，可删除
};

#define kAddPhotoImageViewNotification @"AddPhotoImageViewNotification"

@class PhotoBrowserViewController, PhotoAssetModel;
@protocol PhotoBrowserDelegate <NSObject>

@optional
// 获取相簿中的全部照片资源
- (NSUInteger)numberOfPhotosInPhotoBrowser:(PhotoBrowserViewController*)photoBrowser;
// 获取选中照片资源
- (NSUInteger)numberOfSelectedPhotosInPhotoBrowser:(PhotoBrowserViewController*)photoBrowser;
// 根据index，从相簿中获取某个照片资源
- (PhotoAssetModel*)photoBrowser:(PhotoBrowserViewController*)photoBrowser photoAtIndex:(NSUInteger)index;
// 根据index，从选中照片数组中获取某个照片资源
- (PhotoAssetModel*)photoBrowser:(PhotoBrowserViewController*)photoBrowser selectedPhotoAtIndex:(NSUInteger)index;
// 取消某个选中照片资源
- (void)photoBrowser:(PhotoBrowserViewController*)photoBrowser cancelSelectedPhoto:(PhotoAssetModel*)photoModel;
// 添加某个选中照片资源
- (void)photoBrowser:(PhotoBrowserViewController*)photoBrowser selectPhoto:(PhotoAssetModel*)photoModel;

@end

@interface PhotoBrowserViewController : UIViewController

@property (nonatomic, weak) id<PhotoBrowserDelegate>delegate;
@property (nonatomic, assign) NSInteger currentPageIndex;
@property (nonatomic, assign) PhotoBrowserType photoType;
@property (nonatomic, assign) NSInteger selectedMaxCount;

@property (nonatomic, copy) void(^updateDataSource) ();

- (id)initWithDelegate:(id<PhotoBrowserDelegate>)delegate;
@end
