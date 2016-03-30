//
//  TDImageTitleCell.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/31.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDImageTitleCell : UITableViewCell

+ (CGFloat)cellHeight;
- (void)configWithTitleString:(NSString*)titleStr andStatus:(NSInteger)status;
@end
