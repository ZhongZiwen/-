//
//  EmotionTabBar.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/25.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmotionTabBar : UIView

@property (nonatomic, strong) UIButton *senderButton;

@property (nonatomic, copy) void(^selectedIndexChangedBlock) (NSInteger);
@property (nonatomic, copy) void(^sendButtonClickedBlock) ();

- (instancetype)initWithFrame:(CGRect)frame andButtonImages:(NSArray*)imagesArray;
@end
