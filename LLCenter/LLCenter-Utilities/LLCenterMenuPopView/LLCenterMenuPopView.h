//
//  LLCenterMenuPopView.h
//  shangketong
//
//  Created by sungoin-zbs on 15/7/10.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LLCenterMenuPopView : UIView

@property (nonatomic, copy) void (^selectBlock)(NSInteger);

- (id)initWithPoint:(CGPoint)point titles:(NSArray*)titles;
- (id)initWithPoint:(CGPoint)point titles:(NSArray*)titles imageNames:(NSArray*)images;
- (void)show;
- (void)dismiss;
@end
