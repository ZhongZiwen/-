//
//  ImageTextDetailCell.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/3.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageTextDetailCell : UITableViewCell

+ (CGFloat)cellHeight;
- (void)configWithImageString:(NSString*)imageStr andText:(NSString*)textStr andDetail:(NSString*)detailStr;
@end
