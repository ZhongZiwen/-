//
//  ToadyHeaderView.h
//  shangketong
//
//  Created by 蒋 on 16/1/14.
//  Copyright (c) 2016年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ToadyHeaderView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIImageView *headerImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UIImageView *rightImgView;

@end
