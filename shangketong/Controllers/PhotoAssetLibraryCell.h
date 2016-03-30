//
//  PhotoAssetLibraryCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/7/15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoAssetLibraryViewController;

@interface PhotoAssetLibraryCell : UITableViewCell

@property (nonatomic, strong) UIImageView *imageView0;
@property (nonatomic, strong) UIImageView *imageView1;
@property (nonatomic, strong) UIImageView *imageView2;
@property (nonatomic, strong) UIButton *button0;
@property (nonatomic, strong) UIButton *button1;
@property (nonatomic, strong) UIButton *button2;

@property (nonatomic, weak) PhotoAssetLibraryViewController *assetLibraryController;
@property (nonatomic, copy) void(^selectButtonPress) (NSInteger, BOOL);
@property (nonatomic, copy) void(^imageViewTap) (NSInteger);

+ (CGFloat)cellHeight;
@end
