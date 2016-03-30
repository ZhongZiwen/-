//
//  XLFScheduleTypeCell.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/10.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XLFScheduleTypeCell : UITableViewCell

+ (CGFloat)cellHeight;
- (void)configWithImageName:(UIImage *)image andText:(NSString*)text;
@end
