//
//  ADImageTitleCell.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/30.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ADImageTitleCell : UITableViewCell

+ (CGFloat)cellHeight;
- (void)configWithApprovalTime:(NSString*)timeStr andResult:(NSInteger)result;
@end
