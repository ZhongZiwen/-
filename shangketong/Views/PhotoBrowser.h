//
//  PhotoBrowser.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoBrowser, PhotoItem;

@protocol PhotoBrowserDelegate <NSObject>

@optional

@end
@interface PhotoBrowser : UIView

@property (weak, nonatomic) id<PhotoBrowserDelegate>delegate;
@property (assign, nonatomic) CGFloat backgroundScale;

+ (instancetype)sharedInstance;

- (void)showWithImageViews:(NSArray*)views selectedView:(UIImageView*)selectedView;
- (void)showWithItems:(NSArray *)items selectedItem:(PhotoItem *)selectedItem;
@end
