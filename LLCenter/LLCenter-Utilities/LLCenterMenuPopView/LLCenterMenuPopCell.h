//
//  CustomPopCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/7/10.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LLCenterMenuPopCell : UITableViewCell

+ (CGFloat)cellHeight;
- (void)configWithTitle:(NSString*)title andImageName:(NSString*)imageName;
@end
