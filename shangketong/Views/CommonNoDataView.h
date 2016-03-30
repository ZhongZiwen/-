//
//  CommonNoDataView.h
//  shangketong
//
//  Created by sungoin-zjp on 15-8-6.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommonNoDataView : UIView

@property (nonatomic, copy) void(^optionBtnClickBlock)(void);

@property (nonatomic, copy) NSString *btnTitle;
@property (nonatomic, copy) NSString *labelTitle;
@property (nonatomic, copy) NSString *imgName;

@property (nonatomic, copy) NSString *crmImgName;

@end
