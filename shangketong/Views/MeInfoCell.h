//
//  MeInfoCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/7/8.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MeInfoCell : UITableViewCell

+ (CGFloat)cellHeightWith:(NSString*)string;
- (void)configWithTitleString:(NSString*)titleStr andDetailString:(NSString*)detailStr;
@end
