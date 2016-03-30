//
//  ActivityRecordToolView.h
//  shangketong
//
//  Created by sungoin-zbs on 15/11/18.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityRecordToolView : UIView

@property (copy, nonatomic) void(^transmitBtnClickedBlock)(void);
@property (copy, nonatomic) void(^commentBtnClickedBlock)(void);
@property (copy, nonatomic) void(^likeBtnClickedBlock)(void);

- (void)configWithModel:(Record*)record;
@end
