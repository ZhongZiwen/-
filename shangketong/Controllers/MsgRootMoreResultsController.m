//
//  MsgRootMoreResultsController.m
//  shangketong
//
//  Created by 蒋 on 15/11/20.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "MsgRootMoreResultsController.h"
#import "MsgRootSearchCell.h"
#import "ChatViewController.h"
#import "IM_FMDB_FILE.h"

@interface MsgRootMoreResultsController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation MsgRootMoreResultsController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *V = [[UIView alloc] initWithFrame:CGRectZero];
    [_tableViewResult setTableFooterView:V];
    self.title = [_resultArray[0] safeObjectForKey:@"groupName"];
    // Do any additional setup after loading the view from its nib.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _resultArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MsgRootSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"msgRootSearchCellIdentifier"];
    if (!cell) {
        cell = [[MsgRootSearchCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"msgRootSearchCellIdentifier"];
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"MsgRootSearchCell" owner:self options:nil];
        cell = (MsgRootSearchCell *)[array objectAtIndex:0];
        [cell awakeFromNib];
        [cell setFrameForAlliPhone];
    }
    [cell configWithDict:_resultArray[indexPath.row]];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return _titelSting;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView selectRowAtIndexPath:nil animated:YES scrollPosition:UITableViewScrollPositionNone];
    ChatViewController *chatController = [[ChatViewController alloc] init];
    chatController.hidesBottomBarWhenPushed = YES;
    NSDictionary *dict = _resultArray[indexPath.row];
    /*
     content = "\U7231\U75af3\U3001\U7231\U75af2\U52a0\U5165\U5230\U8ba8\U8bba\U7ec4\U4e2d\U3002";
     groupId = 23;
     groupName = "\U7231\U75af1,\U7231\U75af4,\U848b\U6653\U98de,\U7231\U75af3,\U7231\U75af2";
     icons = "";
     messageId = 178;
     msgTime = 1447835780434;
     */
    chatController.titleName = [dict safeObjectForKey:@"groupName"];
    NSString *groupID = [dict safeObjectForKey:@"groupId"];
    chatController.groupID = groupID;
    chatController.messageIndex = [[dict safeObjectForKey:@"messageIndex"] integerValue];
    chatController.messageID = [dict safeObjectForKey:@"messageId"];
    chatController.pushType = ControllerPushTypeMessageVC;
    chatController.flag_FromWhereInto = @"searchVC";
    if (_BlackGroupIdBlock) {
        _BlackGroupIdBlock(groupID);
    }
    chatController.RefreshDataSourceBlock = ^(NSDictionary *dict, NSString *sting) {
        //插入消息
        if (sting && sting.length > 0) {
            [IM_FMDB_FILE update_IM_ConversationListGroupID:groupID withUnsendSting:[NSString stringWithFormat:@"[草稿]%@", sting]];
        } else {
            [IM_FMDB_FILE update_IM_ConversationListGroupWithInfo:[self changeNotficationToMessageDic:dict]];
            //修改已读消息number  和 未读消息数
            [IM_FMDB_FILE update_IM_ConversationListGroupID:groupID withReadNumber:[NSString stringWithFormat:@"%@", [dict objectForKey:@"number"]] withUnReadNumber:@"0"];
        }
        [IM_FMDB_FILE update_IM_ConversationListGroupID:[NSString stringWithFormat:@"%@", [dict objectForKey:@"to"]] withShow:@"1"];
        [IM_FMDB_FILE closeDataBase];
    };
    //修改已读消息number  和 未读消息数
//    [IM_FMDB_FILE update_IM_ConversationListGroupID:groupID withReadNumber:model.m_number withUnReadNumber:@"0"];
//    [IM_FMDB_FILE closeDataBase];
    
    [self.navigationController pushViewController:chatController animated:YES];

}
- (NSDictionary *)changeNotficationToMessageDic:(NSDictionary *)dict {
    NSMutableDictionary *messagedict = [NSMutableDictionary dictionary];
    [messagedict setObject:[dict objectForKey:@"content"] forKey:@"content"];
    [messagedict setObject:[NSString stringWithFormat:@"%@", [dict objectForKey:@"number"]] forKey:@"number"];
    [messagedict setObject:[NSString stringWithFormat:@"%@", [dict objectForKey:@"type"]] forKey:@"type"];
    [messagedict setObject:[NSString stringWithFormat:@"%@", [dict objectForKey:@"to"]] forKey:@"id"];
    [messagedict setObject:[NSString stringWithFormat:@"%@", [dict objectForKey:@"id"]] forKey:@"userId"];
    NSString *timeStr = @"";
    long dateTime = 0;
    if (dict && [dict objectForKey:@"time"]) {
        timeStr = [CommonFuntion getStringForTime:[[dict safeObjectForKey:@"time"] longLongValue]];
        dateTime = [[dict safeObjectForKey:@"time"] longLongValue];
    }
//    NSInteger value = [CommonFuntion getTimeDaysSinceToady:timeStr];
//    if (value == 0) {
//        timeStr = [timeStr substringWithRange:NSMakeRange(11, 5)];
//    } else if (value == 1) {
//        timeStr = @"昨天";
//    } else if (value > 1 && value <=7) {
//        NSArray *weekDaysArray = @[@"星期日", @"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"星期六"];
//        NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:dateTime / 1000];
//        NSInteger index = [CommonFuntion getCurDateWeekday:date];
//        timeStr = [weekDaysArray objectAtIndex:index - 1];
//    } else {
//        timeStr = [timeStr substringToIndex:10];
//    }
    [messagedict setObject:@(dateTime) forKey:@"time"];
    [messagedict setObject:timeStr forKey:@"sendTime"];
    
    
    if ([[dict allKeys] containsObject:@"resource"] && [CommonFuntion checkNullForValue:[dict objectForKey:@"resource"]]) {
        NSDictionary *resourceDic =  [CommonFuntion dictionaryWithJsonString:[dict objectForKey:@"resource"]];
        [messagedict setObject:@"1" forKey:@"isHave"];
        [messagedict setObject:[NSString stringWithFormat:@"%@", [resourceDic objectForKey:@"type"]] forKey:@"r_type"];
        
    } else {
        [messagedict setObject:@"0" forKey:@"isHave"];
        [messagedict setObject:@"" forKey:@"r_type"];
    }
    return messagedict;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
