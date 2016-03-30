//
//  ChatMessage.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/27.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//


#import "ChatMessage.h"
#import "CommonFuntion.h"
#import "ContactModel.h"
#import "IM_FMDB_FILE.h"

@implementation ChatMessage

- (ChatMessage*)initWithDictionary:(NSDictionary *)dict withNSArray:(NSArray *)usersArray{
    self = [super init];
    if (self) {
        self.isRead = YES;
        self.msg_id = [NSString stringWithFormat:@"%@", [dict objectForKey:@"id"]];
        self.msg_time = [NSString stringWithFormat:@"%lld", [[dict objectForKey:@"time"] longLongValue]];
        self.msg_uid = [[dict objectForKey:@"userId"] integerValue];
        self.isMe = [[NSString stringWithFormat:@"%ld", self.msg_uid] isEqualToString:appDelegateAccessor.moudle.userId];
        self.msg_number = [NSString stringWithFormat:@"%@", [dict objectForKey:@"number"]];
        self.msg_content = [dict objectForKey:@"content"];
        self.type = [NSString stringWithFormat:@"%@", [dict objectForKey:@"type"]];
//        if ([[dict allKeys] containsObject:@"myself"]) {
//            if ([[dict objectForKey:@"myself"] isEqualToString:@"send"]) {
//                _msg_state = MessageStateSend;
//            } else if ([[dict objectForKey:@"myself"] isEqualToString:@"recevied"]){
//                _msg_state = MessageStateRecevied;
//
//            } else {
//                _msg_state = MessageStateFail;
//            }
//        } else {
//            _msg_state = MessageStateRecevied;
//        }
        if (usersArray && usersArray.count > 0) {
            for (ContactModel *model in usersArray) {
                if (self.msg_uid == model.userID) {
                    self.user_name = model.contactName;
                    self.user_icon = model.imgHeaderName;
                    self.user_uid = [NSString stringWithFormat:@"%ld", model.userID];
                }
            }
        }
        if ([self.type isEqualToString:@"1"]) {
            if ([CommonFuntion checkNullForValue:[dict objectForKey:@"resourceView"]] || [CommonFuntion checkNullForValue:[dict objectForKey:@"resource"]]) {
                self.hasResourceView = YES;
                NSDictionary *r_dict = [NSDictionary dictionary];
                if ([CommonFuntion checkNullForValue:[dict objectForKey:@"resourceView"]]) {
                    r_dict = [dict objectForKey:@"resourceView"];
                } else {
                    r_dict = [CommonFuntion dictionaryWithJsonString:[dict objectForKey:@"resource"]];
                }
                
                self.msg_type = [[r_dict objectForKey:@"type"] integerValue];
                switch (self.msg_type) {
                    case ChatMessageTypeImage:
                    {
                        self.msg_imageUrl = [NSString stringWithFormat:@"%@%@/%@", HTTPURL_IM_IMG_VOICE, appDelegateAccessor.moudle.userCompanyId,[r_dict objectForKey:@"fileName"]];
                        self.msg_imageName = [r_dict objectForKey:@"name"];
                        self.msg_imageWidth = 200;
                        self.msg_imageHeight = 250;
                    }
                        break;
                    case ChatMessageTypeVoice:
                    {

                        self.msg_voiceUrl = [NSString stringWithFormat:@"%@%@/%@", HTTPURL_IM_IMG_VOICE, appDelegateAccessor.moudle.userCompanyId,[r_dict objectForKey:@"fileName"]];

                        self.msg_voiceDuration = [[r_dict objectForKey:@"second"] integerValue];
                        self.msg_voiceName = [r_dict objectForKey:@"name"];
                        self.isRead = NO;
                    }
                        break;
                    case ChatMessageTypeFile:
                    {
                        self.msg_fileName = [r_dict safeObjectForKey:@"name"];
                        self.msg_fileUrl = [NSString stringWithFormat:@"%@%@/%@", HTTPURL_IM_IMG_VOICE, appDelegateAccessor.moudle.userCompanyId, [r_dict safeObjectForKey:@"fileName"]];
                        if ([r_dict objectForKey:@"size"]) {
                            NSInteger sizeNum = [[r_dict objectForKey:@"size"] integerValue];
                            NSLog(@"文件大小：%ld", sizeNum);
                            self.msg_fileSize = [NSString stringWithFormat:@"%ld", sizeNum];
                        }
                    }
                        break;
                    default:
                        break;
                }
            }
        } else {
            self.hasResourceView = NO;
        }
    }
    return self;
}

+ (ChatMessage*)initWithDictionary:(NSDictionary *)dict withNSArray:(NSArray *)usersArray{
    ChatMessage *message = [[ChatMessage alloc] initWithDictionary:dict withNSArray:usersArray];
    return message;
}
@end
