//
//  StartChatViewController.h
//  shangketong
//
//  Created by 蒋 on 16/1/26.
//  Copyright (c) 2016年 sungoin. All rights reserved.
//

#import "BaseViewController.h"

typedef  NS_ENUM(NSInteger, ControllerPopType){
    ControllerPopTypeBack = 0, //返回上层
    ControllerPopTypeInto //进入下一层
};

@interface StartChatViewController : BaseViewController

@property (nonatomic, strong) NSArray *GroupContactArray;
@property (nonatomic, copy) void (^BackContactsBlock)(NSArray *array);
@property (nonatomic, assign) ControllerPopType flag_controller;
@property (nonatomic, strong) NSString *groupType;//0（两人对话） 1（讨论组）
//进入IM 获取一次通讯录
- (void)getContactDataSourceFromSever;

@end
