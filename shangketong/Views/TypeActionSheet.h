//
//  TypeActionSheet.h
//  shangketong
//
//  Created by sungoin-zbs on 15/9/21.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TypeModel;

@interface TypeActionSheet : UIView

@property (strong, nonatomic) NSArray *sourceArray;
@property (copy, nonatomic) void(^valueBlock)(TypeModel *item);

- (instancetype)initWithTitle:(NSString*)title;
- (void)show;
- (void)dismiss;
@end
