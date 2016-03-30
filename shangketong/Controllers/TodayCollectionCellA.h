//
//  TodayCollectionCellA.h
//  shangketong
//
//  Created by 蒋 on 16/1/13.
//  Copyright (c) 2016年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TodayCollectionCellA : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;

@property (strong, nonatomic) IBOutlet UIImageView *imgNew;


@end
