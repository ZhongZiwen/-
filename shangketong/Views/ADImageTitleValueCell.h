//
//  ADImageTitleValueCell.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/30.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ADImageTitleValueCell : UITableViewCell

+ (CGFloat)cellHeight;
- (void)configWithApprovalState:(NSInteger)state;
@end
