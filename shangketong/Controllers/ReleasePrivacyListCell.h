//
//  ReleasePrivacyListCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/7/15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReleasePrivacyListCell : UITableViewCell

+ (CGFloat)cellHeight;
- (void)configWithImageName:(NSString*)imageName andTitle:(NSString*)title andCount:(NSInteger) count;
@end
