//
//  MenuChoiceView.h
//  shangketong
//
//  Created by sungoin-zbs on 15/7/8.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuChoiceView : UIView

@property (nonatomic, strong) NSArray *menuArray;
@property (nonatomic, copy) void(^selectedBlock) (NSInteger);

- (id)initWithFrame:(CGRect)frame withDefaultIndex:(NSInteger)index;
- (void)setIndexSelect:(NSInteger)index;
@end
