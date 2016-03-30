//
//  OpportunityHeaderView.h
//  shangketong
//
//  Created by sungoin-zbs on 15/11/14.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CRMDetail;

@interface OpportunityHeaderView : UIView

@property (copy, nonatomic) void(^opportunityStageBlock)(void);
@property (copy, nonatomic) void(^customerBlock)(void);
@property (copy, nonatomic) void(^staffsBlock)(void);

- (void)configWithObj:(CRMDetail*)item;
@end
