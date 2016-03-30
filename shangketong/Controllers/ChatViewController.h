//
//  ChatViewController.h
//  MenuDemo
//  聊天界面
//  Created by sungoin-zbs on 15/5/26.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef  NS_ENUM(NSInteger, ControllerPushType){
    ControllerPushTypeMessageVC, //会话列表进入
    ControllerPushTypeStartChatVC //创建组
};

@interface ChatViewController : BaseViewController
@property (nonatomic, strong) NSString *groupID;
@property (nonatomic, strong) NSArray *usersArray;
@property (nonatomic, strong) NSString *groupType;
@property (nonatomic, strong) NSString *titleName;
@property (nonatomic, assign) NSInteger unReadMessageCount;
@property (nonatomic, assign) ControllerPushType pushType;
@property (nonatomic, strong) NSString *companyType;
@property (nonatomic, strong) NSString *unSendStr;
@property (nonatomic, assign) NSInteger messageIndex;
@property (nonatomic, strong) NSString *messageID;

@property (nonatomic, assign) NSInteger messageNumber;
@property (nonatomic, copy) void (^RefreshDataSourceBlock)(NSDictionary *dict, NSString *sting);
@property (nonatomic, strong) NSString *flag_FromWhereInto;
@end

