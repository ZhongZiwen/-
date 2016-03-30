//
//  FunnelChoiceView.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/30.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FunnelChoiceView : UIView

@property (nonatomic, copy) void(^selectedBlock) (NSInteger);
@end
