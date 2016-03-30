//
//  MassMsgViewController.h
//  shangketong
//  发短信页面
//  Created by sungoin-zjp on 15-6-15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@protocol MassMsgDelegate;

@interface MassMsgViewController : UIViewController<MFMessageComposeViewControllerDelegate>

@property (assign, nonatomic) id <MassMsgDelegate>delegate;

@property(strong,nonatomic)NSMutableArray *arrayAllContact;

///类型  contact / customer
@property(strong,nonatomic)NSString *typeContact;
///类型  commondetailscall/userinfo  详情/个人资料页面发送消息 直接传递name phone
@property(strong,nonatomic)NSString *contactName;
@property(strong,nonatomic)NSString *contactPhone;
@end


@protocol MassMsgDelegate<NSObject>
@required

///发送短信结果
- (void)resultOfMassMsg:(BOOL)isSuccess desc:(NSString *)desc;
@end
