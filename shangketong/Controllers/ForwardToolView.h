//
//  ForwardToolView.h
//  shangketong
//
//  Created by sungoin-zjp on 15-8-6.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForwardToolView : UIView

@property (nonatomic, copy) void(^privateBlock)(void);
@property (nonatomic, copy) void(^atBlock)(void);

@property (nonatomic, copy) NSString *privateBtnTitle;

@end
