//
//  ChooseDiscussionGroupController.m
//  shangketong
//
//  Created by 蒋 on 15/9/16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ChooseDiscussionGroupController.h"
#import "ChatViewController.h"
#import "ChooseGroupCell.h"
#import "ConversationListModel.h"
#import "IM_FMDB_FILE.h"
#import "CommonFuntion.h"
#import "Message_RootViewController.h"
#import "CommonNoDataView.h"

@interface ChooseDiscussionGroupController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *dataSourceArray;
@property (nonatomic, strong) NSMutableArray *groupImgArray;
@property (nonatomic, strong) CommonNoDataView *commonNoDataView;
@end

@implementation ChooseDiscussionGroupController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择已有讨论组";
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableViewGroup setTableFooterView:v];
    [_tableViewGroup setSeparatorInset:UIEdgeInsetsMake(0, 64, 0, 0)];
    _dataSourceArray = [NSMutableArray arrayWithCapacity:0];
    // Do any additional setup after loading the view from its nib.
    NSArray *resultArray = [IM_FMDB_FILE result_IM_ConversationListWithResultType:@"normal"];
    self.groupImgArray = [NSMutableArray arrayWithCapacity:0];
    for (ConversationListModel *model in resultArray) {
        if ([model.b_type isEqualToString:@"1"]) {
            [_dataSourceArray addObject:model];
            NSArray *userArray = [IM_FMDB_FILE result_IM_UserList:model.b_id];
            NSMutableArray *userImgArray = [NSMutableArray arrayWithCapacity:0];
            for (ContactModel *userModel in userArray) {
                [userImgArray addObject:userModel.imgHeaderName];
            }
            [self.groupImgArray addObject:userImgArray];
        }
    }
    if (_dataSourceArray.count > 0) {
        [self clearViewNoData];
    } else {
        [self clearViewNoData];
        [self setViewNoData:@"暂无讨论组"];
    }
    
    
    
}
- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSourceArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChooseGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChooseGroupIdentifier"];
    if (!cell) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"ChooseGroupCell" owner:self options:nil];
        cell = (ChooseGroupCell *)[array objectAtIndex:0];
        [cell awakeFromNib];
    }
    ConversationListModel *model = _dataSourceArray[indexPath.row];
    [cell configWithModel:model withImgArray:_groupImgArray[indexPath.row]];
    return cell;
}
- (CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
   
    
    ChatViewController *chatController = [[ChatViewController alloc] init];
    chatController.hidesBottomBarWhenPushed = YES;
    ConversationListModel *model = _dataSourceArray[indexPath.row];
    chatController.titleName = model.b_name;
    chatController.groupID = model.b_id;
    chatController.pushType = ControllerPushTypeMessageVC;
    
    // 会话列表界面
    [[NSNotificationCenter defaultCenter] postNotificationName:@"messageListUnread" object:@{@"groupId" : model.b_id}];
    
    [self.navigationController pushViewController:chatController animated:YES];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 没有数据时的view
-(void)setViewNoData:(NSString *)title{
    
    self.commonNoDataView = [CommonFuntion commonNoDataViewIcon:@"list_empty.png" Title:title optionBtnTitle:@""];
    
    [_tableViewGroup addSubview:self.commonNoDataView];
}


-(void)clearViewNoData{
    if (self.commonNoDataView) {
        [self.commonNoDataView removeFromSuperview];
    }
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
