//
//  LeadHeaderView.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/20.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CRMDetail;

@interface LeadHeaderView : UIView

@property (copy, nonatomic) void(^phoneBtnClickedBlock)(void);
@property (copy, nonatomic) void(^emailBtnClickedBlock)(void);
@property (copy, nonatomic) void(^positionBtnClickedBlock)(void);
@property (copy, nonatomic) void(^stateBtnClickedBlock)(void);

- (void)configWithModel:(CRMDetail*)item;
@end
