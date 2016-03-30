//
//  UITapImageView.h
//  shangketong
//
//  Created by sungoin-zbs on 15/7/16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITapImageView : UIImageView

@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, copy) void(^imageViewTapBlock)(NSInteger);
@end
