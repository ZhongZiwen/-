//
//  Hearder_View.h
//  HeaderView_Demo
//  讨论组头像
//  Created by 蒋 on 15/10/12.
//  Copyright (c) 2015年 蒋. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Hearder_View : UIView
//数组中元素最少为三个（项目需求）
- (instancetype)initWithFrame:(CGRect)frame;
- (void)customImageViews:(NSArray *)imagesArray;
@end
