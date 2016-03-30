//
//  PhotoBrowserTableViewCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/7/20.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoAssetModel;
@interface PhotoBrowserTableViewCell : UITableViewCell

@property (nonatomic, copy) void(^cellTapBlock)(void);

- (void)configWithModel:(PhotoAssetModel*)photoModel;
@end
