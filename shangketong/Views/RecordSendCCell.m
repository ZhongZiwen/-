//
//  RecordSendCCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/27.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "RecordSendCCell.h"
#import "PhotoAssetModel.h"

#define kSpaceWidth 15
#define kWidth (kScreen_Width - 2 * kSpaceWidth - 3 * 10) / 4.0

@interface RecordSendCCell ()

@end

@implementation RecordSendCCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        if (!_iconView) {
            _iconView = [[UIImageView alloc] init];
            [_iconView setY:10];
            [_iconView setWidth:kWidth];
            [_iconView setHeight:kWidth];
            _iconView.contentMode = UIViewContentModeScaleAspectFill;
            _iconView.clipsToBounds = YES;
            [self.contentView addSubview:_iconView];
        }
    }
    return self;
}

- (void)setPhotoAsset:(PhotoAssetModel *)photoAsset {
    if (photoAsset) {
        _iconView.image = [UIImage imageWithCGImage:photoAsset.asset.thumbnail];
    }
    else {
        _iconView.image = [UIImage imageNamed:@"add-normal"];
    }
}

+ (CGSize)ccellSize {
    return CGSizeMake(kWidth, kWidth);
}
@end
