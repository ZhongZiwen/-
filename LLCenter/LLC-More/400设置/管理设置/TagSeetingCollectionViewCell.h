//
//  TagSeetingCollectionViewCell.h
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-13.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TagSeetingCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIButton *btnTag;

@property (strong, nonatomic) IBOutlet UIImageView *imgDeleteIcon;



-(void)setCellFrame:(NSIndexPath *)indexPath;

///删除标签
@property (nonatomic, copy) void (^DeleteTagBlock)(NSInteger index);

@end
