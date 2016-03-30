//
//  UnReadNumberModle.h
//  
//
//  Created by sungoin-zjp on 16/3/3.
//
//

#import <Foundation/Foundation.h>

@interface UnReadNumberModle : NSObject<NSCoding>

///待办提醒+通知+公告+企业微信的未读消息数

///企业微信
@property (nonatomic, strong) NSString *number_message;
///待办提醒
@property (nonatomic, strong) NSString *number_remind;
///通知
@property (nonatomic, strong) NSString *number_inform;
///公告
@property (nonatomic, strong) NSString *number_announcement;

@end
