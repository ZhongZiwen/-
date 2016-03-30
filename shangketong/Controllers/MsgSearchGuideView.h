//
//  MsgSearchGuideView.h
//  shangketong
//  消息主页面搜索提示图
//  Created by 蒋 on 15/12/23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MsgSearchGuideView : UIView

@property (nonatomic, copy) void(^optionBtnClickBlock)(void);

@property (nonatomic, copy) NSString *btnTitle;
@property (nonatomic, copy) NSString *labelTitle;
//一个大图
@property (nonatomic, copy) NSString *imgName;

//四个图
@property (nonatomic, copy) NSString *imgNameOne;
@property (nonatomic, copy) NSString *imgNameTwo;
@property (nonatomic, copy) NSString *imgNameThree;
@property (nonatomic, copy) NSString *imgNameFour;

@end
