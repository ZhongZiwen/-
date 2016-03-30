//
//  PhotoViewState.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoViewState : UIView

@property (nonatomic, strong) UIView *superview;
@property (nonatomic, strong) UIImage *minImage;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) BOOL userInteratctionEnabled;
@property (nonatomic, assign) CGAffineTransform transform;

+ (PhotoViewState *)viewStateForView:(UIImageView *)view;
- (void)setStateWithView:(UIImageView *)view;
@end
