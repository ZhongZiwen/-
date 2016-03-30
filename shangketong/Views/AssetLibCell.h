//
//  AssetLibCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/9/16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AssetLibCell : UITableViewCell

+ (CGFloat)cellHeight;
- (void)configImageView:(UIImage*)image Title:(NSString*)title andDetail:(NSString*)detail;
@end
