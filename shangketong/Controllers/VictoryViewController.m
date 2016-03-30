//
//  VictoryViewController.m
//  
//
//  Created by sungoin-zjp on 15/12/25.
//
//

#import "VictoryViewController.h"
#import "VictoryCell.h"

#import "OpportunityDetailController.h"
#import "SaleChance.h"

#import "CommonNoDataView.h"
#import "CommonFunc.h"


@interface VictoryViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableview;
///数据源
@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, strong) CommonNoDataView *commonNoDataView;

@end

@implementation VictoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initData];
    [self initTableview];
    ///请求数据
    [self sendCmdGetVictory];
}



///初始化数据
-(void)initData{
    
}



#pragma mark - 初始化tablview
-(void)initTableview{
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height-60) style:UITableViewStylePlain];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.sectionFooterHeight = 0;
    self.tableview.separatorColor = COLOR_TABLEVIEW_SEPARATOR_LINE;
    self.tableview.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
    [self.view addSubview:self.tableview];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableview setTableFooterView:v];
}


#pragma mark - 底部view
-(void)creatBottomView:(NSString *)sumSalesAmount{
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreen_Height-60, kScreen_Width, 60)];
    bottomView.backgroundColor = [UIColor whiteColor];
    
    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 1)];
    line.image = [UIImage imageNamed:@"line.png"];
    
    UILabel *labelSumSalesAmount = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 60)];
    labelSumSalesAmount.font = [UIFont systemFontOfSize:16.0];
    labelSumSalesAmount.textColor = LIGHT_BLUE_COLOR;
    
    labelSumSalesAmount.text = [NSString stringWithFormat:@"   销售机会合计(元):%@",sumSalesAmount];
    
    [bottomView addSubview:line];
    [bottomView addSubview:labelSumSalesAmount];
    
    [self.view addSubview:bottomView];
}

#pragma mark -- tableview

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSLog(@"self.dataSource count:%ti",[self.dataSource count]);
    if (self.dataSource) {
        return [self.dataSource count];
    }
    return 0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VictoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VictoryCellIdentify"];
    if (!cell)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"VictoryCell" owner:self options:nil];
        cell = (VictoryCell*)[array objectAtIndex:0];
        [cell awakeFromNib];
    }

    NSDictionary *item = [self.dataSource objectAtIndex:indexPath.row];
    [cell setCellDetails:item];
    
    return cell;

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self gotoOpportunitysDetails:[self.dataSource objectAtIndex:indexPath.row]];
}



///销售机会
-(void)gotoOpportunitysDetails:(NSDictionary *)item{
    SaleChance *saleChance = [NSObject objectOfClass:@"SaleChance" fromJSON:item];
    // 缓存最近浏览
    [[FMDBManagement sharedFMDBManager] casheCRMRecentlyDataSourceWithName:kTableName_opportunity item:item];
    OpportunityDetailController *detailController = [[OpportunityDetailController alloc] init];
    detailController.title = @"销售机会";
    detailController.id = saleChance.id;
    [self.navigationController pushViewController:detailController animated:YES];
}

/*
 saleChance/getVictoryOpportunitys.do 获取喜报列表接口
 参数：startDate开始时间
 endDate结束时间
 都传空表示查看当天喜报。传时间即指定时间喜报：XXXX-XX-XX
 */

#pragma mark - 获取喜报列表
-(void)sendCmdGetVictory{
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params setObject:self.strStartDate forKey:@"startDate"];
    [params setObject:self.strEndDate forKey:@"endDate"];
    
    NSLog(@"params:%@",params);
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",MOBILE_SERVER_IP_CRM, VICTORY_OPPORTUNITY_LIST_ACTION] params:params success:^(id responseObj) {
        [hud hide:YES];
        NSLog(@"responseObj:%@",responseObj);
        //字典转模型
        NSDictionary *resultdic = responseObj;
        
        if ([resultdic objectForKey:@"status"] && [[resultdic objectForKey:@"status"] integerValue] == 0) {
            
            self.dataSource = [resultdic objectForKey:@"saleChances"] ;
            
            ///添加底部view
            [self creatBottomView:[resultdic safeObjectForKey:@"sumSalesAmount"]];
            
            NSLog(@"self.dataSource:%@",self.dataSource);
            
        } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self sendCmdGetVictory];
            };
            [comRequest loginInBackground];
        }else{
            NSString *desc = @"";
            if ([responseObj objectForKey:@"desc"]) {
                desc = [responseObj safeObjectForKey:@"desc"];
            }
            if ([desc isEqualToString:@""]) {
                desc = @"加载失败";
            }
            [CommonFuntion showToast:desc inView:self.view];
        }
        
        [self  notifyNoDataView];
    } failure:^(NSError *error) {
        NSLog(@"error:%@",error);
        [hud hide:YES];
        kShowHUD(NET_ERROR);
        [self  notifyNoDataView];
    }];
}

/*
 {
 desc = "<null>";
 saleChances =     (
 {
 customerName = "\U51cc\U9704";
 focus = 1;
 id = 173;
 money = 369;
 name = ujn;
 ownerName = "\U591c\U6708";
 }
 );
 status = 0;
 sumSalesAmount = 369;
 }
 */




#pragma mark - 没有数据时的view
-(void)notifyNoDataView{
    if (self.dataSource && [self.dataSource count] > 0) {
        [self clearViewNoData];
    }else{
        [self setViewNoData:@"暂无喜报"];
    }
    [self.tableview reloadData];
}

-(void)setViewNoData:(NSString *)title{
    if (self.commonNoDataView == nil) {
        self.commonNoDataView = [CommonFunc commonNoDataViewIcon:@"list_empty.png" Title:title optionBtnTitle:@""];
    }
    
    [self.tableview addSubview:self.commonNoDataView];
}

-(void)clearViewNoData{
    if (self.commonNoDataView) {
        [self.commonNoDataView removeFromSuperview];
    }
}




@end
