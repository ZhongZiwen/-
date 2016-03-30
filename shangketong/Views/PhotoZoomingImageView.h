//
//  PhotoZoomingImageView.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoZoomingImageView : UIView

@property (nonatomic, readonly) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, readonly) BOOL isViewing;
@end
