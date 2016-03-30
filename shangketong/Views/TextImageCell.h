//
//  TextImageCell.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/3.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextImageCell : UITableViewCell

- (void)configWithText:(NSString*)textStr andImage:(UIImage*)image;
+ (CGFloat)cellHeight;
@end
