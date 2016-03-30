//
//  WRWorkResultItem.h
//  shangketong
//
//  Created by sungoin-zbs on 15/7/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WRWorkResultItem : UIView

@property (nonatomic, copy) void(^itemClickBlock) (NSInteger);

+ (WRWorkResultItem*)initWithTitleString:(NSString*)titleStr andValueString:(NSString*)valueStr;
- (WRWorkResultItem*)initWithTitleString:(NSString*)titleStr andValueString:(NSString*)valueStr;
@end
