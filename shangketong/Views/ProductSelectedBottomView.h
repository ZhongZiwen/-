//
//  ProductSelectedBottomView.h
//  shangketong
//
//  Created by sungoin-zbs on 15/11/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductSelectedBottomView : UIView

@property (copy, nonatomic) void(^bottomBtnPressBlock)(void);
@property (copy, nonatomic) void(^confireBtnPressBlock)(void);

- (void)updateCountLabelWithCount:(NSInteger)count;
@end
