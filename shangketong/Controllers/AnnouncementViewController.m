//
//  AnnouncementViewController.m
//  shangketong
//
//  Created by 蒋 on 16/3/8.
//  Copyright (c) 2016年 sungoin. All rights reserved.
//

#import "AnnouncementViewController.h"
#import "AnnounceDetailsController.h"
#import "AnnounceCell.h"
#import "AnnounceModel.h"
#import "MJRefresh.h"
#import "AFNHttp.h"
#import "CommonNoDataView.h"
#import "CommonUnReadNumberUtil.h"

@interface AnnouncementViewController ()
{
    NSInteger announcePage;  //部门公告页码
}
@property (nonatomic, strong) NSMutableArray *announceSourceArray; // 部门公告
@property (nonatomic, strong) CommonNoDataView *commonNoDataView;

@end

@implementation AnnouncementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    announcePage = 1;
    _announceSourceArray = [NSMutableArray arrayWithCapacity:0];
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.separatorColor = COLOR_TABLEVIEW_SEPARATOR_LINE;
    _tableView.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
    [self getAllDataSourceFromSever];
    [self setupRefresh];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _announceSourceArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 60.0f;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AnnounceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AnnounceCellIdentifier"];
    if (!cell) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"AnnounceCell" owner:self options:nil];
        cell = (AnnounceCell *)[array objectAtIndex:0];
        [cell awakeFromNib];
        [cell setFrameAllPhone];
    }
    AnnounceModel *model = _announceSourceArray[indexPath.row];
    [cell configWithModel:model];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AnnounceDetailsController *controller = [[AnnounceDetailsController alloc] init];
    AnnounceModel *model = _announceSourceArray[indexPath.row];
    if ([model.isHasRead isEqualToString:@"1"]) {
        model.isHasRead = @"0";
        
        ///消息数--
        [CommonUnReadNumberUtil unReadNumberDecrease:3  number:1];
//        if (_announcementCount > 0) {
//            _announcementCount --;
//            if (_announcementCount == 0) {
//                _announLabel.hidden = YES;
//            } else {
//                _announLabel.text = [NSString stringWithFormat:@"%ld", _announcementCount];
//            }
//        } else {
//            _announcementCount = 0;
//            _announLabel.hidden = YES;
//        }
    }
    controller.title = @"部门公告";
    controller.announceID = model.announce_ID;
    controller.announceContent = model.content;
    [self.navigationController pushViewController:controller animated:YES];
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section],nil] withRowAnimation:UITableViewRowAnimationNone];
}
- (void)getAllDataSourceFromSever {
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:appDelegateAccessor.window];
    [appDelegateAccessor.window addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    __weak typeof(self) weak_self = self;
    [params setObject:[NSNumber numberWithInteger:announcePage] forKey:@"pageNo"];
    [params setObject:[NSNumber numberWithInt:20] forKey:@"pageSize"];
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, GET_ANNOUNCEMENT_LIST] params:params success:^(id responseObj) {
        NSLog(@"responseObj:%@",responseObj);
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            if ([responseObj objectForKey:@"announceMents"]) {
                [self changeDataSourceType:[responseObj objectForKey:@"announceMents"]];
            }
        } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getAllDataSourceFromSever];
            };
            [comRequest loginInBackground];
        }
        [hud hide:YES];
        [weak_self  reloadRefeshView];
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [weak_self  reloadRefeshView];
    }];
}
- (void)changeDataSourceType:(NSArray *)dataArray {
        if (announcePage == 1) {
            [_announceSourceArray removeAllObjects];
        }
        for (NSDictionary *dict in dataArray) {
            AnnounceModel *model = [[AnnounceModel alloc] initWithDictionary:dict];
            [_announceSourceArray addObject:model];
        }
        ///有数据返回
        if (dataArray && [dataArray count] > 0) {
            ///页码++
            [self clearViewNoData];
            if ([dataArray count] == 20) {
                announcePage ++;
            }else
            {
                ///隐藏上拉刷新
                [self.tableView setFooterHidden:YES];
            }
            
        }else{
            ///返回为空
            [self clearViewNoData];
            NSString *string = @"暂无部门公告";
            [self setViewNoData:string];
            [self.tableView setFooterHidden:YES];
        }
}
#pragma mark - 没有数据时的view
-(void)setViewNoData:(NSString *)title{
    
    self.commonNoDataView = [CommonFuntion commonNoDataViewIcon:@"list_empty.png" Title:title optionBtnTitle:@""];
    
    [_tableView addSubview:self.commonNoDataView];
}


-(void)clearViewNoData{
    if (self.commonNoDataView) {
        [self.commonNoDataView removeFromSuperview];
    }
}
#pragma mark -  上拉加载 下来刷新
//集成刷新控件
- (void)setupRefresh
{
    // dateKey用于存储刷新时间，可以保证不同界面拥有不同的刷新时间
    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing) dateKey:@"announcement"];
    //上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
}

// 结束加载
-(void)reloadRefeshView{
    // 刷新列表
    [self.tableView reloadData];
    [self.tableView footerEndRefreshing];
    [self.tableView headerEndRefreshing];
}

// 下拉
- (void)headerRereshing
{
    NSLog(@"headerRereshing--下拉-->");
    
    if ([self.tableView isFooterRefreshing]) {
        [self.tableView headerEndRefreshing];
        return;
    }
    announcePage = 1;
    [self getAllDataSourceFromSever];
}

// 上拉
- (void)footerRereshing
{
    NSLog(@"footerRereshing--上拉-->");
    
    if ([self.tableView isHeaderRefreshing]) {
        [self.tableView footerEndRefreshing];
        return;
    }
    [self getAllDataSourceFromSever];
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
