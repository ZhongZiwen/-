//
//  MRTitleDetailCell.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/1.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRTitleDetailCell : UITableViewCell

+ (CGFloat)cellHeightWithDetailString:(NSString*)detailStr;
- (void)configWithTitleString:(NSString*)titleStr andDetailString:(NSString*)detailStr;
@end
