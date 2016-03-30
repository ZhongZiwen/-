//
//  ConversationListModel.m
//  shangketong
//
//  Created by 蒋 on 15/10/13.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ConversationListModel.h"
#import "CommonFuntion.h"
#import "ChatMessage.h"
#import "ContactModel.h"
#import "IM_FMDB_FILE.h"

@implementation ConversationListModel

- (ConversationListModel *)initWithDictionary:(NSDictionary *)dict{
    self = [super init];
    _imgsArray = [NSMutableArray array];
    _messageListArray  = [NSMutableArray array];
    _usersListArray = [NSMutableArray array];
    if (self) {
        if (dict) {
            //body层次
            _b_versionCode = [[dict safeObjectForKey:@"versionCode"] longLongValue];
            _b_createDate = [CommonFuntion getStringForTime:[[dict objectForKey:@"cocreateDateunt"] longLongValue]];
            _b_id = [NSString stringWithFormat:@"%@", [dict objectForKey:@"id"]];
            _b_msgNumber = [NSString stringWithFormat:@"%@", [dict objectForKey:@"msgNumber"]];
            _b_type = [NSString stringWithFormat:@"%@", [dict objectForKey:@"type"]];
            
            NSString *titleStr = [dict objectForKey:@"name"];
            _b_name = titleStr;
            
            _b_unReadNumber = [NSString stringWithFormat:@"%@", [dict objectForKey:@"unReadNumber"]];
            
            //userIdViewList 层
            if ([CommonFuntion checkNullForValue:[dict objectForKey:@"userIdViewList"]]) {
                NSMutableArray *resultSqlArray = [NSMutableArray arrayWithCapacity:0];
                NSArray *array = [dict objectForKey:@"userIdViewList"];
                NSString *sqlId = @"";
                for (NSDictionary *u_dict in array) {
                    if ([sqlId isEqualToString:@""]) {
                        sqlId = [NSString stringWithFormat:@"'%ld'", [[u_dict safeObjectForKey:@"id"] integerValue]];
                    } else {
                        sqlId = [NSString stringWithFormat:@"%@,'%ld'", sqlId, [[u_dict safeObjectForKey:@"id"] integerValue]];
                    }
                }
                NSString *sqlStr = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE id in(%@)", @"ADDRESSBOOKLIST", sqlId];
                
                
                [resultSqlArray addObject:sqlStr];
                NSArray *resultArray = [IM_FMDB_FILE batch_result_IM:resultSqlArray withType:ResultTypeContacat];
                [_usersListArray addObjectsFromArray:resultArray];

                for (ContactModel *model in  resultArray) {
                    _u_images = model.imgHeaderName;
                    _u_id = [NSString stringWithFormat:@"%ld", model.userID];
                     NSLog(@"-----讨论组中的成员%@-----当前登陆用户%@-----当前成员%@", sqlId, appDelegateAccessor.moudle.userId, _u_id);
                    //这里针对单人和群聊的头像做一个筛选
                    if ([_b_type isEqualToString:@"1"]) {
                        [_imgsArray addObject:_u_images];
                    } else {
                        if (![_u_id isEqualToString:appDelegateAccessor.moudle.userId]) {
                            [_imgsArray addObject:_u_images];
                        }
                    }
                    if ([_u_id isEqualToString:appDelegateAccessor.moudle.userId]) {
                        _u_name = model.contactName;
                    }
                    
                }
            }
            //userViewList层
            if ([CommonFuntion checkNullForValue:[dict objectForKey:@"userViewList"]]) {
                NSArray *array = [dict objectForKey:@"userViewList"];
//                [IM_FMDB_FILE delete_IM_UsersListListGroupID:_b_id];
                for (NSDictionary *u_dict in array) {
                    ContactModel *modle = [ContactModel initWithDataSource:u_dict];
                    [_usersListArray addObject:modle];
//                    [IM_FMDB_FILE insert_IM_UsersListListGroupID:_b_id withGroupType:_b_type withInfo:modle];
                    _u_images = [u_dict safeObjectForKey:@"images"];
                    _u_id = [NSString stringWithFormat:@"%@", [u_dict objectForKey:@"id"]];
                    
                    
                    //这里针对单人和群聊的头像做一个筛选
                    if ([_b_type isEqualToString:@"1"]) {
                        [_imgsArray addObject:_u_images];
                    } else {
                        if (![_u_id isEqualToString:appDelegateAccessor.moudle.userId]) {
                            [_imgsArray addObject:_u_images];
                        }
                    }
                    if ([_u_id isEqualToString:appDelegateAccessor.moudle.userId]) {
                        _u_name = [u_dict objectForKey:@"name"];
                    }
                }
            }
            
            if ([CommonFuntion checkNullForValue:[dict objectForKey:@"messageView"]]) {
                NSDictionary *m_dic = [dict objectForKey:@"messageView"];
                _m_content = [m_dic objectForKey:@"content"];
                _m_groupId = [NSString stringWithFormat:@"%@",[m_dic objectForKey:@"groupId"] ];
                _m_id = [NSString stringWithFormat:@"%@",[m_dic objectForKey:@"id"]];
                _m_number = [NSString stringWithFormat:@"%@",[m_dic objectForKey:@"number"]];
//                long dateTime = 0;
                if (m_dic && [m_dic objectForKey:@"time"]) {
                    _m_lastMessageTime = [NSString stringWithFormat:@"%@", [m_dic safeObjectForKey:@"time"]];
                    _m_time = [CommonFuntion getStringForTime:[[m_dic safeObjectForKey:@"time"] longLongValue]];
//                    dateTime = [[m_dic safeObjectForKey:@"time"] longLongValue];
                }
//                NSInteger value = [CommonFuntion getTimeDaysSinceToady:_m_time];
//                if (value == 0) {
//                    _m_time = [_m_time substringWithRange:NSMakeRange(11, 5)];
//                } else if (value == 1) {
//                    _m_time = @"昨天";
//                } else if (value > 1 && value <=7) {
//                    NSArray *weekDaysArray = @[@"星期日", @"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"星期六"];
//                    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:dateTime / 1000];
//                    NSInteger index = [CommonFuntion getCurDateWeekday:date];
//                    _m_time = [weekDaysArray objectAtIndex:index - 1];
//                } else {
//                    _m_time = [_m_time substringToIndex:10];
//                }
                _m_type = [m_dic objectForKey:@"type"];
                _m_userId = [NSString stringWithFormat:@"%@",[m_dic objectForKey:@"userId"]];
                
                if ([CommonFuntion checkNullForValue:[m_dic objectForKey:@"resourceView"]]) {
                    _isHave = YES;
                     NSDictionary *r_dic = [m_dic objectForKey:@"resourceView"];
                    _r_type = [NSString stringWithFormat:@"%@", [r_dic objectForKey:@"type"]];
                } else {
                    _isHave = NO;
                }
            }
        }
    }
    return self;
}
+ (ConversationListModel *)initWithDictionary:(NSDictionary *)dict{
    ConversationListModel *model = [[ConversationListModel alloc] initWithDictionary:dict];
    return model;
}
@end
