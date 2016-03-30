//
//  TextValueCell.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/3.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextValueCell : UITableViewCell

+ (CGFloat)cellHeightWithValueString:(NSString*)valueStr;
- (void)configWithTextString:(NSString*)textStr andValueString:(NSString*)valueStr;
@end
