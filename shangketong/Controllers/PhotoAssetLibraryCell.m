//
//  PhotoAssetLibraryCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "PhotoAssetLibraryCell.h"
#import <POPSpringAnimation.h>
#import "PhotoAssetLibraryViewController.h"

#define kImageViewWidth ([UIScreen mainScreen].bounds.size.width - 2*5) / 3.0
#define kButtonWidth    30

@implementation PhotoAssetLibraryCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImage *graph_normal = [UIImage imageNamed:@"multi_graph_normal"];
        UIImage *graph_select = [UIImage imageNamed:@"multi_graph_select"];
        
        UITapGestureRecognizer *tap0 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTap:)];
        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTap:)];
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTap:)];
        
        _imageView0 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, kImageViewWidth, kImageViewWidth)];
        _imageView0.userInteractionEnabled = YES;
        [_imageView0 addGestureRecognizer:tap0];
        [self.contentView addSubview:_imageView0];
        _button0 = [UIButton buttonWithType:UIButtonTypeCustom];
        _button0.frame = CGRectMake(kImageViewWidth-kButtonWidth, 0, kButtonWidth, kButtonWidth);
        [_button0 setImage:graph_normal forState:UIControlStateNormal];
        [_button0 setImage:graph_select forState:UIControlStateSelected];
        [_button0 addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
        [_imageView0 addSubview:_button0];
        
        _imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(5 + kImageViewWidth, 5, kImageViewWidth, kImageViewWidth)];
        _imageView1.userInteractionEnabled = YES;
        [_imageView1 addGestureRecognizer:tap1];
        [self.contentView addSubview:_imageView1];
        _button1 = [UIButton buttonWithType:UIButtonTypeCustom];
        _button1.frame = CGRectMake(kImageViewWidth-kButtonWidth, 0, kButtonWidth, kButtonWidth);
        [_button1 setImage:graph_normal forState:UIControlStateNormal];
        [_button1 setImage:graph_select forState:UIControlStateSelected];
        [_button1 addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
        [_imageView1 addSubview:_button1];
        
        _imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake((5 + kImageViewWidth)*2, 5, kImageViewWidth, kImageViewWidth)];
        _imageView2.userInteractionEnabled = YES;
        [_imageView2 addGestureRecognizer:tap2];
        [self.contentView addSubview:_imageView2];
        _button2 = [UIButton buttonWithType:UIButtonTypeCustom];
        _button2.frame = CGRectMake(kImageViewWidth-kButtonWidth, 0, kButtonWidth, kButtonWidth);
        [_button2 setImage:graph_normal forState:UIControlStateNormal];
        [_button2 setImage:graph_select forState:UIControlStateSelected];
        [_button2 addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
        [_imageView2 addSubview:_button2];
        
    }
    return self;
}

- (void)imageViewTap:(UITapGestureRecognizer*)tap {
    UIImageView *imageView = (UIImageView*)tap.view;
    if (self.imageViewTap) {
        self.imageViewTap(imageView.tag);
    }
}

- (void)buttonPress:(UIButton*)sender {
    
    if (sender.selected) {
        
        sender.selected = NO;

        UIImageView *imageView = (UIImageView*)sender.superview;
        POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
        scaleAnimation.fromValue = [NSValue valueWithCGSize:CGSizeMake(1.1, 1.1)];
        scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1, 1)];
        scaleAnimation.springBounciness = 8.f;
        [imageView.layer pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];
        
    }else {
        
        if (_assetLibraryController.assetManager.selectedArray.count >= _assetLibraryController.maxCount) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"你最多只能选择%d张照片", _assetLibraryController.maxCount] delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles: nil];
            [alertView show];
            return;
        }
        
        sender.selected = YES;
        
        UIImageView *imageView = (UIImageView*)sender.superview;
        POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
        scaleAnimation.fromValue = [NSValue valueWithCGSize:CGSizeMake(0.9, 0.9)];
        scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1, 1)];
        scaleAnimation.springBounciness = 8.f;
        [imageView.layer pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];
    }
    
    if (self.selectButtonPress) {
        self.selectButtonPress(sender.tag, sender.selected);
    }
}

+ (CGFloat)cellHeight {
    return kImageViewWidth + 5;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
