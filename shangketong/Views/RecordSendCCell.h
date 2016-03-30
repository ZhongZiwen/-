//
//  RecordSendCCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/27.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoAssetModel;

@interface RecordSendCCell : UICollectionViewCell

@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) PhotoAssetModel *photoAsset;
+ (CGSize)ccellSize;
@end
