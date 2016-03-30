//
//  MRFileCell.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/1.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRFileCell : UITableViewCell

+ (CGFloat)cellHeight;
- (void)configWithFileType:(NSInteger)type andFileName:(NSString*)name;
@end
