//
//  ActivityRecordImagesView.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/18.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ActivityRecordImagesView.h"
#import "FileModel.h"
//#import "PhotoBrowser.h"
//#import "PhotoItem.h"
#import "PhotoBroswerVC.h"

#define kTag_imageView 35436

@interface ActivityRecordImagesView ()

@property (strong, nonatomic) UIImageView *imageView0;
@property (strong, nonatomic) UIImageView *imageView1;
@property (strong, nonatomic) UIImageView *imageView2;
@property (strong, nonatomic) UIImageView *imageView3;
@property (strong, nonatomic) UIImageView *imageView4;
@property (strong, nonatomic) UIImageView *imageView5;
@property (strong, nonatomic) UIImageView *imageView6;
@property (strong, nonatomic) UIImageView *imageView7;
@property (strong, nonatomic) UIImageView *imageView8;

@property (strong, nonatomic) NSMutableArray *imageViewsArray;
@end

@implementation ActivityRecordImagesView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        _imageViewsArray = [[NSMutableArray alloc] initWithCapacity:0];
        
        [self addSubview:self.imageView0];
        [self addSubview:self.imageView1];
        [self addSubview:self.imageView2];
        [self addSubview:self.imageView3];
        [self addSubview:self.imageView4];
        [self addSubview:self.imageView5];
        [self addSubview:self.imageView6];
        [self addSubview:self.imageView7];
        [self addSubview:self.imageView8];
    }
    return self;
}

- (void)configWithArray:(NSArray *)imagesArray {
    [_imageViewsArray removeAllObjects];
    
    if (imagesArray.count % 3 == 0) {
        [self setHeight:imagesArray.count / 3 * (kWidth_imageView + 10)];
    }else {
        [self setHeight:(imagesArray.count / 3 + 1) * (kWidth_imageView + 10)];
    }
    
    for (int i = 0; i < 9; i ++) {
        UIImageView *imageView = (UIImageView*)[self viewWithTag:kTag_imageView + i];
        if (i < imagesArray.count) {
            FileModel *file = imagesArray[i];
            imageView.hidden = NO;
            [imageView sd_setImageWithURL:[NSURL URLWithString:file.url] placeholderImage:[UIImage imageNamed:@"user_icon_default_90"]];
            [imageView setX:(kWidth_imageView + 10) * (i % 3)];
            [imageView setY:(kWidth_imageView + 10) * (i / 3)];
            [imageView setWidth:kWidth_imageView];
            [imageView setHeight:kWidth_imageView];
            
//            PhotoItem *item = [[PhotoItem alloc] init];
//            item.url = file.url;
//            item.minUrl = file.minUrl;
//            item.srcImageView = imageView;
//            [_imageViewsArray addObject:item];
            
            PhotoModel *pbModel=[[PhotoModel alloc] init];
            pbModel.mid = i+1;
            pbModel.image_HD_U =file.url;
            pbModel.sourceImageView = imageView;
            [_imageViewsArray addObject:pbModel];
            
            continue;
        }

        imageView.hidden = YES;
    }
}

- (void)tapGesture:(UITapGestureRecognizer*)sender {
    UIImageView *selectedImageView = (UIImageView *)sender.view;
//    PhotoItem *selectedItem = _imageViewsArray[selectedImageView.tag - kTag_imageView];
//    
//    [PhotoBrowser sharedInstance].backgroundScale = 1.0;
//    [[PhotoBrowser sharedInstance] showWithItems:_imageViewsArray selectedItem:selectedItem];
    
    [PhotoBroswerVC show:self.handleVC type:PhotoBroswerVCTypeUserInfo index:selectedImageView.tag - kTag_imageView photoModelBlock:^NSArray *{
        return _imageViewsArray;
    }];
    
}

- (UIImageView*)configImageView {
    UIImageView *imageView = [[UIImageView alloc] init];
    [imageView setWidth:kWidth_imageView];
    [imageView setHeight:kWidth_imageView];
    imageView.userInteractionEnabled = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [imageView addGestureRecognizer:tap];
    
    return imageView;
}

- (UIImageView*)imageView0 {
    if (!_imageView0) {
        _imageView0 = [self configImageView];
        _imageView0.tag = kTag_imageView;
    }
    return _imageView0;
}

- (UIImageView*)imageView1 {
    if (!_imageView1) {
        _imageView1 = [self configImageView];
        _imageView1.tag = kTag_imageView + 1;
    }
    return _imageView1;
}

- (UIImageView*)imageView2 {
    if (!_imageView2) {
        _imageView2 = [self configImageView];
        _imageView2.tag = kTag_imageView + 2;
    }
    return _imageView2;
}

- (UIImageView*)imageView3 {
    if (!_imageView3) {
        _imageView3 = [self configImageView];
        _imageView3.tag = kTag_imageView + 3;
    }
    return _imageView3;
}

- (UIImageView*)imageView4 {
    if (!_imageView4) {
        _imageView4 = [self configImageView];
        _imageView4.tag = kTag_imageView + 4;
    }
    return _imageView4;
}

- (UIImageView*)imageView5 {
    if (!_imageView5) {
        _imageView5 = [self configImageView];
        _imageView5.tag = kTag_imageView + 5;
    }
    return _imageView5;
}

- (UIImageView*)imageView6 {
    if (!_imageView6) {
        _imageView6 = [self configImageView];
        _imageView6.tag = kTag_imageView + 6;
    }
    return _imageView6;
}

- (UIImageView*)imageView7 {
    if (!_imageView7) {
        _imageView7 = [self configImageView];
        _imageView7.tag = kTag_imageView + 7;
    }
    return _imageView7;
}

- (UIImageView*)imageView8 {
    if (!_imageView8) {
        _imageView8 = [self configImageView];
        _imageView8.tag = kTag_imageView + 8;
    }
    return _imageView8;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
