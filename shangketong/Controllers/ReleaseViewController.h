//
//  ReleaseViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/7/13.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TypeOfOptionDynamic) {
    TypeOfOptionDynamicRelease,
    TypeOfOptionDynamicForward,
    TypeOfOptionDynamicCRMRecord
};

@interface ReleaseViewController : UIViewController

///转发时的原动态
@property(nonatomic,strong) NSDictionary *itemDynamic;
///发布成功后刷新UI
@property (nonatomic, copy) void (^ReleaseSuccessNotifyData)(void);

@property (nonatomic, assign) TypeOfOptionDynamic typeOfOptionDynamic;

///是在群组或部分发布还是在工作圈发布   department  group   zone
@property(nonatomic,strong) NSString *typeOfRelease;
@property (nonatomic, assign) long long parentId;
@property (nonatomic, strong) NSString *titleStr; //接收上一届面传过来的

// 定位
@property (nonatomic, copy) NSString *locationStr;
@property (nonatomic, assign) float latitude;
@property (nonatomic, assign) float longitude;

// 活动记录
@property (copy, nonatomic) NSString *recordId;    // 活动类型id

@end
