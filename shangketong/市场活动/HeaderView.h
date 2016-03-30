//
//  HeaderView.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/8.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CRMDetail;

@interface HeaderView : UIView

@property (copy, nonatomic) void(^stateBtnClickedBlock)(void);
@property (copy, nonatomic) void(^staffClickedBlock)(void);

- (void)configWithModel:(CRMDetail*)item;
@end
