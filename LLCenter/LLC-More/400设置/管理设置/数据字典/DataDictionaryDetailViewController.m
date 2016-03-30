//
//  DataDictionaryViewController.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-16.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "DataDictionaryDetailViewController.h"
#import "LLCenterUtility.h"
#import "CommonFunc.h"
#import "CustomPopView.h"
#import "CommonNoDataView.h"
#import "DataDictionaryDetailCell.h"
#import "CustomNarTitleView.h"
#import "SmartConditionModel.h"
#import "AddOrEditDataDictionaryViewController.h"


@interface DataDictionaryDetailViewController ()<UITableViewDataSource,UITableViewDelegate,SWTableViewCellDelegate>{
    
    ///默认项移除状态  show  hide  ""
    NSString *removeStatus;
    ///normal delete
    NSString *actionType;
    
    ///来源 类型等
    NSString *actionName;
    ///客户来源 客户类型
    NSString *actionNameForNewView;
    
    ///参数name与id
    NSString *paramName;
    NSString *paramId;
    
    ///客户类型
    NSArray *customerType;
    ///客户来源
    NSArray *customerSource;
    ///联系人类型
    NSArray *linkmanType;
    
    ///销售类型
    NSArray * saleTypeList;
    ///销售阶段
    NSArray * saleStageList;
    ///销售状态
    NSArray * saleStatusList;
    
    ///售后类型
    NSArray * serviceTypeList;
    ///售后状态
    NSArray * serviceStatusList;

    
}

@property (nonatomic, assign) NSInteger curIndex;
@property (nonatomic, strong) CustomNarTitleView *customTitleView;
@property (nonatomic, strong) CommonNoDataView *commonNoDataView;
@property(strong,nonatomic) UITableView *tableview;
@property(strong,nonatomic) NSMutableArray *dataSource;

@end

@implementation DataDictionaryDetailViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"";
    [super customBackButton];
    [self addNavBar];
    [self addNarMenu];
    self.view.backgroundColor = COLOR_BG;
    
    [self initData];
    [self initTableView];
    ///请求数据
    [self sendCmdGetDataDictionary];
}


#pragma mark - Nav Bar
-(void)addNavBar{
    
//    UIButton *rightButton=[UIButton buttonWithType:UIButtonTypeCustom];
//    rightButton.frame=CGRectMake(0, 0, 25, 16);
//    [rightButton setBackgroundImage:[UIImage imageNamed:@"icon_more_function.png"] forState:UIControlStateNormal];
//    [rightButton setBackgroundImage:[UIImage imageNamed:@"icon_more_function.png"] forState:UIControlStateHighlighted];
//    [rightButton addTarget:self action:@selector(rightBarButtonAction) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
//    [self.navigationItem setRightBarButtonItem:rightBarButton];
    
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(rightBarButtonAction)];
        self.navigationItem.rightBarButtonItem = addButton;
    
}

///
-(void)rightBarButtonAction{
//    [self showPopView];
    [self gotoAddOrEditView:@"add" withItem:nil];
}




///完成删除操作
-(void)addRightOkBarBtn{
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(rightOkBarButtonAction)];
}


-(void)rightOkBarButtonAction{
    self.navigationItem.rightBarButtonItem = nil;
    [self addNavBar];
    actionType = @"normal";
    [self.tableview reloadData];
}


-(void)showPopView{
    NSString *addDictionary = [NSString stringWithFormat:@"新增%@",actionName];
    NSString *deleteDictionary = [NSString stringWithFormat:@"删除%@",actionName];
    CustomPopView *popView = [[CustomPopView alloc] initWithPoint:CGPointMake(0, 64+64) titles:@[addDictionary, deleteDictionary] imageNames:@[@"icon_add_dictionary.png", @"icon_delete_img.png"]];
    __weak typeof(self) weak_self = self;
    popView.selectBlock = ^(NSInteger index) {
        if (index == 0) {
            [weak_self gotoAddOrEditView:@"add" withItem:nil];
        }else if (index == 1){
            [self deleteDictionary];
        }
    };
    
    [popView show];
}

///获取当前字典的个数
-(NSInteger)getDicAllCount{
    NSInteger count = 0;
    
    if ([[[[self.dataSource objectAtIndex:0] objectAtIndex:0] safeObjectForKey:@"default"] integerValue] == -1) {
        
    }else{
        count++;
    }
    
    if (self.dataSource.count > 1) {
        count += [[self.dataSource objectAtIndex:1] count];
    }
    return count;
}


///新增、编辑页面
-(void)gotoAddOrEditView:(NSString *)type withItem:(NSDictionary *)item{
    
    ///新增
    if ([type isEqualToString:@"add"]) {
        ///当前数据字典的个数   不能超过12个
        if (self.dataSource && [self getDicAllCount] > 11) {
            [CommonFuntion showToast:[NSString stringWithFormat:@"%@最多增加12项",actionNameForNewView] inView:self.view];
            return;
        }
    }
    
    
    AddOrEditDataDictionaryViewController *aev = [[AddOrEditDataDictionaryViewController alloc] init];
    aev.detail = item;
    aev.actionType = type;
    aev.actionName = actionNameForNewView;
    aev.paramName = paramName;
    if ([type isEqualToString:@"edit"]) {
        aev.paramId = paramId;
    }
    aev.urlName = [self getActionUrl:@"add"];
    
    __weak typeof(self) weak_self = self;
    aev.NotifyDataDictionaryList = ^(){
        [weak_self.dataSource removeAllObjects];
        [weak_self sendCmdGetDataDictionary];
    };
    
    [self.navigationController pushViewController:aev animated:YES];
}


-(void)deleteDictionary{
    [self addRightOkBarBtn];
    actionType = @"delete";
    [self.tableview reloadData];
}


#pragma mark - 根据action获取url
-(NSString *)getActionUrl:(NSString *)action{
    NSString *url = @"";
    ///新增、编辑
    if ([action isEqualToString:@"add"] || [action isEqualToString:@"edit"]) {
        switch (self.viewType) {
            case 1:
            {
                if (self.curIndex == 0) {
                    url = LLC_SAVE_CUSTOMER_SOURCE_ACTION;
                }else if (self.curIndex == 1){
                    url = LLC_SAVE_CUSTOMER_TYPE_ACTION;
                }
            }
                break;
            case 2:
            {
                if (self.curIndex == 0) {
                    url = LLC_SAVE_LINKMAN_TYPE_ACTION;
                }
            }
                break;
            case 3:
            {
                if (self.curIndex == 0) {
                    url = LLC_SAVE_SALE_TYPE_ACTION;
                }else if (self.curIndex == 1){
                    url = LLC_SAVE_SALE_STAGE_ACTION;
                }else if (self.curIndex == 2){
                    url = LLC_SAVE_SALE_STATUS_ACTION;
                }
            }
                break;
            case 4:
            {
                if (self.curIndex == 0) {
                    url = LLC_SAVE_AFTER_SERVICE_TYPE_ACTION;
                }else if (self.curIndex == 1){
                    url = LLC_SAVE_AFTER_SERVICE_STATUS_ACTION;
                }
            }
                break;
                
            default:
                break;
        }
    }else{
        ///删除
        switch (self.viewType) {
            case 1:
            {
                if (self.curIndex == 0) {
                    url = LLC_DELETE_CUSTOMER_SOURCE_ACTION;
                }else if (self.curIndex == 1){
                    url = LLC_DELETE_CUSTOMER_TYPE_ACTION;
                }
            }
                break;
            case 2:
            {
                if (self.curIndex == 0) {
                    url = LLC_DELETE_LINKMAN_TYPE_ACTION;
                }
            }
                break;
            case 3:
            {
                if (self.curIndex == 0) {
                    url = LLC_DELETE_SALE_TYPE_ACTION;
                }else if (self.curIndex == 1){
                    url = LLC_DELETE_SALE_STAGE_ACTION;
                }else if (self.curIndex == 2){
                    url = LLC_DELETE_SALE_STATUS_ACTION;
                }
            }
                break;
            case 4:
            {
                if (self.curIndex == 0) {
                    url = LLC_DELETE_AFTER_SERVICE_TYPE_ACTION;
                }else if (self.curIndex == 1){
                    url = LLC_DELETE_AFTER_SERVICE_STATUS_ACTION;
                }
            }
                break;
                
            default:
                break;
        }
    }
    return url;
}

#pragma mark - Title 菜单
-(void)addNarMenu{

    if (self.viewType == 2) {
        self.title = @"联系人类型";
        return;
    }
    
    _curIndex = 0;
    __weak typeof(self) weak_self = self;

    self.customTitleView.sourceArray = [self getMenuDataWithViewType];
    self.customTitleView.index = 0;
    self.customTitleView.valueBlock = ^(NSInteger index) {
        
        weak_self.curIndex = index;
        [weak_self notifyDataDictionay];
    };
    self.navigationItem.titleView = self.customTitleView;
}


- (CustomNarTitleView*)customTitleView {
    if (!_customTitleView) {
        _customTitleView = [[CustomNarTitleView alloc] init];
        //        _customTitleView.defalutTitleString = @"黑名单";
        _customTitleView.superViewController = self;
    }
    return _customTitleView;
}



-(NSMutableArray *)getMenuDataWithViewType{
    NSArray *arrTitle;
    switch (self.viewType) {
        case 1:
            arrTitle = [NSArray arrayWithObjects:@"客户来源",@"客户类型", nil];
            break;
        case 2:
            arrTitle = [NSArray arrayWithObjects:@"联系人类型", nil];
            break;
        case 3:
            arrTitle = [NSArray arrayWithObjects:@"销售类型",@"销售阶段",@"销售状态", nil];
            break;
        case 4:
            arrTitle = [NSArray arrayWithObjects:@"售后类型",@"售后状态", nil];
            break;
        
            
        default:
            arrTitle = nil;
            break;
    }
    return [self getMenuTitleData:arrTitle];
}

-(NSMutableArray *)getMenuTitleData:(NSArray *)arrTitle{
    if (arrTitle == nil) {
        return nil;
    }
    NSMutableArray *arraySour = [[NSMutableArray alloc] init];
    for (int i=0; i<arrTitle.count; i++) {
        SmartConditionModel *model = [[SmartConditionModel alloc] init];
        model.name = [arrTitle objectAtIndex:i];
        [arraySour addObject:model];
    }
    return arraySour;
}


///刷新数据
-(void)notifyDataDictionay{
//    if ([removeStatus isEqualToString:@"show"]){
//        removeStatus = @"hide";
//        [self.tableview reloadData];
//    }
    
    NSArray *arrDictionary;
    switch (self.viewType) {
        case 1:
        {
            if (self.curIndex == 0) {
                actionName = @"来源";
                actionNameForNewView = @"客户来源";
                paramName = @"sourceName";
                paramId = @"sourceId";
                if (customerSource && [customerSource count]> 0) {
                    arrDictionary = customerSource;
                }
                
            }else if (self.curIndex == 1){
                actionName = @"类型";
                actionNameForNewView = @"客户类型";
                paramName = @"typeName";
                paramId = @"typeId";
                if (customerType && [customerType count]> 0) {
                   arrDictionary = customerType;
                }
            }
        }
            break;
        case 2:
        {
            if (self.curIndex == 0) {
                actionName = @"类型";
                actionNameForNewView = @"联系人类型";
                paramName = @"typeName";
                paramId = @"typeId";
                if (linkmanType && [linkmanType count]> 0) {
                    arrDictionary = linkmanType;
                }
                
            }
        }
            break;
        case 3:
        {
            if (self.curIndex == 0) {
                actionName = @"类型";
                actionNameForNewView = @"销售类型";
                paramName = @"typeName";
                paramId = @"typeId";
                if (saleTypeList && [saleTypeList count]> 0) {
                    arrDictionary = saleTypeList;
                }
                
            }else if (self.curIndex == 1){
                actionName = @"阶段";
                actionNameForNewView = @"销售阶段";
                paramName = @"stageName";
                paramId = @"stageId";
                if (saleStageList && [saleStageList count]> 0) {
                    arrDictionary = saleStageList;
                }
                
            }else if (self.curIndex == 2){
                actionName = @"状态";
                actionNameForNewView = @"销售状态";
                paramName = @"statusName";
                paramId = @"statusId";
                if (saleStatusList && [saleStatusList count]> 0) {
                    arrDictionary = saleStatusList;
                }
                
            }
        }
            break;
        case 4:
        {
            if (self.curIndex == 0) {
                actionName = @"类型";
                actionNameForNewView = @"售后类型";
                paramName = @"typeName";
                paramId = @"typeId";
                if (serviceTypeList && [serviceTypeList count]> 0) {
                    arrDictionary = serviceTypeList;
                }
                
            }else if (self.curIndex == 1){
                actionName = @"状态";
                actionNameForNewView = @"售后状态";
                paramName = @"statusName";
                paramId = @"statusId";
                if (serviceStatusList && [serviceStatusList count]> 0) {
                    arrDictionary = serviceStatusList;
                }
                
            }
        }
            break;
            
        default:
            break;
    }
    
    [self initDataDictinary:arrDictionary];
    [self.tableview reloadData];
    [self notifyNoDataView];
}

#pragma mark - 网络请求失败时处理
-(void)setFaildView{
    self.navigationItem.rightBarButtonItem = nil;
    NSString *title = @"";
    switch (self.viewType) {
        case 1:
            title = @"客户";
            break;
        case 2:
            title = @"联系人";
            break;
        case 3:
            title = @"销售";
            break;
        case 4:
            title = @"售后";
            break;
            
        default:
            break;
    }
    self.title = title;
}

#pragma mark - 初始化数据
-(void)initData{
    removeStatus = @"";
    actionType = @"normal";
    actionName = @"";
    self.dataSource = [[NSMutableArray alloc] init];
}


#pragma mark - 组织数据格式
-(void)initDataDictinary:(NSArray *)arrDictionary{
    [self.dataSource removeAllObjects];
    
    NSMutableArray *arrayDefault = [[NSMutableArray alloc] init];
    NSMutableArray *arrayOthers = [[NSMutableArray alloc] init];
    
    NSInteger count = 0;
    if (arrDictionary) {
        count = [arrDictionary count];
    }
    NSDictionary *item;
    
    for (int i=0; i<count; i++) {
        item = [arrDictionary objectAtIndex:i];
        ///默认选项
        if ([[item safeObjectForKey:@"default"] integerValue] == 1) {
            [arrayDefault addObject:item];
        }else{
            [arrayOthers addObject:item];
        }
    }
    
    if ([arrayDefault count] == 0) {
        NSMutableDictionary *itemDefaultNull = [[NSMutableDictionary alloc] init];
        [itemDefaultNull setObject:@"" forKey:@"id"];
        [itemDefaultNull setObject:@"暂无默认项" forKey:@"name"];
        [itemDefaultNull setObject:@"-1" forKey:@"default"];
        
        NSMutableArray *arrDefaultNull = [[NSMutableArray alloc] init];
        [arrDefaultNull addObject:itemDefaultNull];
        [self.dataSource addObject:arrDefaultNull];

    }else{
        [self.dataSource addObject:arrayDefault];
    }
    
    [self.dataSource addObject:arrayOthers];
    
    removeStatus = @"";
}

///初始化collectionview
-(void)initTableView{

    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, DEVICE_BOUNDS_HEIGHT-64) style:UITableViewStyleGrouped];
    [self.tableview registerNib:[UINib nibWithNibName:@"DataDictionaryDetailCell" bundle:nil] forCellReuseIdentifier:@"DataDictionaryDetailCellIdentify"];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.sectionFooterHeight = 0;
    [self.view addSubview:self.tableview];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableview setTableFooterView:v];
    
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if ([removeStatus isEqualToString:@"show"]){
        removeStatus = @"hide";
        [self.tableview reloadData];
    }
}


#pragma mark -  tableview

#pragma mark - tableview delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.dataSource) {
        return [self.dataSource count];
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headview =[[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, 40)];
    headview.backgroundColor = COLOR_BG;
    
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 80, 20)];
    labelTitle.textColor = [UIColor blackColor];
    labelTitle.font = [UIFont systemFontOfSize:15.0];
    if (section == 0) {
        labelTitle.text = @"默认项";
    }else{
        labelTitle.text = @"数据项";
    }
    
    [headview addSubview:labelTitle];
    
    return headview;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([self.dataSource objectAtIndex:section]) {
        return [[self.dataSource objectAtIndex:section] count];
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"DataDictionaryDetailCellIdentify";
    DataDictionaryDetailCell *cell = (DataDictionaryDetailCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"DataDictionaryDetailCell" owner:self options:nil];
        cell = (DataDictionaryDetailCell*)[array objectAtIndex:0];
        [cell awakeFromNib];
    }
    cell.delegate = self;
    NSDictionary *item = [[self.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [cell setCellDetails:item];
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        if ([removeStatus isEqualToString:@"show"]) {
            cell.btnRemove.hidden = NO;

            cell.btnRemove.alpha = 1.0f;
            
            ///移除按钮
            CGSize totalSize = cell.btnRemove.frame.size;
            cell.btnRemove.frame = (CGRect){ DEVICE_BOUNDS_WIDTH,0, 0, totalSize.height };
            
            ///文本
            cell.labelTitle.frame = (CGRect){ 55,15, 200, 20 };
            ///按钮
            cell.btnOption.frame = (CGRect){ 5,5, 40, 40 };
            
            [UIView animateWithDuration:0.5f animations:^{
                cell.btnRemove.frame = (CGRect){ DEVICE_BOUNDS_WIDTH-65,0, totalSize };
                cell.labelTitle.frame = (CGRect){ 55-65,15, 200, 20 };
                cell.btnOption.frame = (CGRect){ 5-65,5, 40, 40 };
            } completion:^(BOOL finished){
               
            }];
            
        }else if ([removeStatus isEqualToString:@"hide"]){
            CGSize totalSize = cell.btnRemove.frame.size;
            cell.btnRemove.frame = (CGRect){ DEVICE_BOUNDS_WIDTH-65,0, totalSize.width, totalSize.height };
            cell.labelTitle.frame = (CGRect){ 55-65,15, 200, 20 };
            cell.btnOption.frame = (CGRect){ 5-65,5, 40, 40 };
            [UIView animateWithDuration:0.5f animations:^{
                
                cell.btnRemove.frame = (CGRect){ DEVICE_BOUNDS_WIDTH,0, totalSize };
                ///文本
                cell.labelTitle.frame = (CGRect){ 55,15, 200, 20 };
                ///按钮
                cell.btnOption.frame = (CGRect){ 5,5, 40, 40 };
            } completion:^(BOOL finished){
                cell.btnRemove.alpha = 0.0f;
                cell.btnRemove.hidden = YES;
            }];
            
        }else{
            ///文本
            cell.labelTitle.frame = (CGRect){ 55,15, 200, 20 };
            ///按钮
            cell.btnOption.frame = (CGRect){ 5,5, 40, 40 };
            cell.btnRemove.hidden = YES;
        }
    }else {
        cell.btnRemove.hidden = YES;
        [cell setLeftAndRightBtn];
    }
    
    
    __weak typeof(self) weak_self = self;
    cell.InsertDefaultDictionaryBlock = ^(){
        NSLog(@"InsertDefaultDictionaryBlock");
        if ([removeStatus isEqualToString:@"show"]){
            removeStatus = @"hide";
        }
        [weak_self.tableview reloadData];
        [weak_self cancelOrInsertDefaultDictionary:[item safeObjectForKey:@"id"] andName:[item safeObjectForKey:@"name"] andAction:@"insert"];
    };
    
    
    cell.ShowRemoveBtnBlock = ^(){
        if ([removeStatus isEqualToString:@""]) {
            removeStatus = @"show";
        }else if ([removeStatus isEqualToString:@"show"]){
            removeStatus = @"hide";
        }else if ([removeStatus isEqualToString:@"hide"]){
            removeStatus = @"show";
        }
        [weak_self.tableview reloadData];
    };
    
    cell.RemoveDefaultDictionaryBlock = ^(){
        NSLog(@"RemoveDefaultDictionaryBlock");
        removeStatus = @"hide";
        [weak_self.tableview reloadData];
        [weak_self cancelOrInsertDefaultDictionary:[item safeObjectForKey:@"id"] andName:[item safeObjectForKey:@"name"] andAction:@"cancel"];
    };
    
    
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([removeStatus isEqualToString:@"show"]){
        removeStatus = @"hide";
        [self.tableview reloadData];
    }
}



#pragma mark - SWTableViewDelegate
- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{
    switch (state) {
        case 0:
            //        NSLog(@"utility buttons closed");
            break;
        case 1:
            //        NSLog(@"left utility buttons open");
            break;
        case 2:
            //        NSLog(@"right utility buttons open");
            break;
        default:
            break;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index
{
    switch (index) {
        case 0:
            //        NSLog(@"left button 0 was pressed");
            break;
        default:
            break;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [self.tableview indexPathForCell:cell];
    NSLog(@"click index:%ld",indexPath.row);
    
    switch (index) {
        case 0:
        {
            NSLog(@"编辑--->");
            ///跳转到编辑页面
            [self gotoAddOrEditView:@"edit" withItem:[[self.dataSource objectAtIndex:1] objectAtIndex:indexPath.row]];
            
            break;
        }
        case 1:
        {
            NSLog(@"删除--->");
            [self showDeleteAlert:indexPath.row];
            break;
        }
            
        default:
            break;
    }
}


- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    // allow just one cell's utility button to be open at once
    return YES;
}

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    switch (state) {
        case 1:
            // set to NO to disable all left utility buttons appearing
            return NO;
            break;
        case 2:
            // set to NO to disable all right utility buttons appearing
            return YES;
            break;
        default:
            break;
    }
    
    return YES;
}



#pragma mark - UIAlertView

///删除提示框
-(void)showDeleteAlert:(NSInteger)index{
    NSString *tag = [[[self.dataSource objectAtIndex:1] objectAtIndex:index] safeObjectForKey:@"name"];
    NSString *messge = [NSString stringWithFormat:@"是否删除当前%@?\n%@",actionNameForNewView,tag];
    UIAlertView *alertCall = [[UIAlertView alloc] initWithTitle:nil message: messge delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    alertCall.tag = index;
    [alertCall show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //外呼
    if (buttonIndex == 1) {
        NSLog(@"delete index:%ti",alertView.tag);
        [self deleteDictionaryByIndex:alertView.tag];
    }
}



#pragma mark - 网络请求

-(void)sendCmdGetDataDictionary{
    removeStatus = @"";
    [self clearViewNoData];
    switch (self.viewType) {
        case 1:
            [self getCustomerDictionary];
            break;
        case 2:
            [self getCustomerDictionary];
            break;
        case 3:
            [self getSaleDictionary];
            break;
        case 4:
            [self getAfterServiceDictionary];
            break;
            
        default:
            break;
    }
    
    
}

#pragma mark - 获取客户来源-类型信息
-(void)getCustomerDictionary{
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:nil];
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_GET_CUSTOMER_DETAILS_DICTIONARY_ACTION] params:params success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"客户来源-类型jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            if ([jsonResponse objectForKey:@"resultMap"]) {
                
                ///类型
                if ([[jsonResponse objectForKey:@"resultMap"] objectForKey:@"customerCategory"] != [NSNull null]) {
                    customerType = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"customerCategory"];
                }
                
                ///来源
                if ([[jsonResponse objectForKey:@"resultMap"] objectForKey:@"customerSource"] != [NSNull null]) {
                    customerSource = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"customerSource"];              }
                
                
                ///联系人类型
                if ([[jsonResponse objectForKey:@"resultMap"] objectForKey:@"linkmanCategory"] != [NSNull null]) {
                    linkmanType = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"linkmanCategory"];
                }
                
                
            }else{
                [CommonFuntion showToast:@"加载异常" inView:self.view];
                [self setFaildView];
            }
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getCustomerDictionary];
            };
            [comRequest loginInBackgroundLLC];
        }
        else {
            //获取失败
            NSString *desc = [jsonResponse safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"加载失败";
            }
            [CommonFuntion showToast:desc inView:self.view];
            [self setFaildView];
        }
        [self notifyDataDictionay];
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
        [self setFaildView];
        [self notifyDataDictionay];
    }];
}


#pragma mark 获取销售字典信息
-(void)getSaleDictionary{
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:nil];
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_GET_SALE_DICTIONARY_ACTION] params:params success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"销售字典jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            if ([jsonResponse objectForKey:@"resultMap"]) {
                
                ///类型
                if ([[jsonResponse objectForKey:@"resultMap"] objectForKey:@"saleTypeList"] != [NSNull null]) {
                    saleTypeList = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"saleTypeList"];
                }
                
                ///阶段
                if ([[jsonResponse objectForKey:@"resultMap"] objectForKey:@"saleStageList"] != [NSNull null]) {
                    saleStageList = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"saleStageList"];
                    
                }
                
                ///状态
                if ([[jsonResponse objectForKey:@"resultMap"] objectForKey:@"saleStatusList"] != [NSNull null]) {
                    saleStatusList = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"saleStatusList"];
                }
                
            }else{
                NSLog(@"data------>:<null>");
                [CommonFuntion showToast:@"加载异常" inView:self.view];
                [self setFaildView];
            }
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getSaleDictionary];
            };
            [comRequest loginInBackgroundLLC];
        }
        else {
            //获取失败
            NSString *desc = [jsonResponse safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"加载失败";
            }
            [CommonFuntion showToast:desc inView:self.view];
            [self setFaildView];
        }
        [self notifyDataDictionay];
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
        [self setFaildView];
        [self notifyDataDictionay];
    }];
}


#pragma mark 获取售后字典信息
-(void)getAfterServiceDictionary{
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:nil];
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_GET_AFTER_SERVICE_DICTIONARY_ACTION] params:params success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"售后字典jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            
            if ([jsonResponse objectForKey:@"resultMap"]) {
                
                ///类型
                if ([[jsonResponse objectForKey:@"resultMap"] objectForKey:@"serviceTypeList"] != [NSNull null]) {
                    serviceTypeList = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"serviceTypeList"];
                    
                }
                
                ///状态
                if ([[jsonResponse objectForKey:@"resultMap"] objectForKey:@"serviceStatusList"] != [NSNull null]) {
                    serviceStatusList = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"serviceStatusList"];
                }
                
            }else{
                NSLog(@"data------>:<null>");
                [CommonFuntion showToast:@"加载异常" inView:self.view];
                [self setFaildView];
            }
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getAfterServiceDictionary];
            };
            [comRequest loginInBackgroundLLC];
        }
        else {
            //获取失败
            NSString *desc = [jsonResponse safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"加载失败";
            }
            [CommonFuntion showToast:desc inView:self.view];
            [self setFaildView];
        }
        [self notifyDataDictionay];
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
        [self setFaildView];
        [self notifyDataDictionay];
    }];
    
}



#pragma mark - 编辑字典信息(移除默认项)
///插入还是移除
-(void)cancelOrInsertDefaultDictionary:(NSString *)dicId andName:(NSString *)dicName andAction:(NSString *)action{
    
    ///传入：flagName
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *rDict = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    NSString *urlName = [self getActionUrl:@"add"];
    [rDict setValue:dicId forKey:paramId];
    [rDict setValue:dicName forKey:paramName];
    if ([action isEqualToString:@"insert"]) {
        [rDict setValue:@"1" forKey:@"default"];
    }else{
        [rDict setValue:@"0" forKey:@"default"];
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:rDict]
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString:%@",jsonString);
    
    ///dic转换为json
    NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rParam setObject:jsonString forKey:@"data"];
    NSLog(@"rParam:%@",rParam);
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,urlName] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"移除默认字典信息jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            ///重新加载数据
            [self sendCmdGetDataDictionary];
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self cancelOrInsertDefaultDictionary:dicId andName:dicName andAction:action];
            };
            [comRequest loginInBackgroundLLC];
        }
        else {
            //获取失败
            NSString *desc = [jsonResponse safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"移除失败";
            }
            [CommonFuntion showToast:desc inView:self.view];
        }
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
    }];
}


#pragma mark - 删除标签

-(void)deleteDictionaryByIndex:(NSInteger)index{
    
    NSString *url = [self getActionUrl:@"delete"];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    NSMutableDictionary *rDict = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rDict setValue:[[[self.dataSource objectAtIndex:1] objectAtIndex:index] safeObjectForKey:@"id"] forKey:paramId];
    [rDict setValue:[[[self.dataSource objectAtIndex:1] objectAtIndex:index] safeObjectForKey:@"name"] forKey:paramName];
    
    NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:rDict]
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString:%@",jsonString);
    
    ///dic转换为json
    NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rParam setObject:jsonString forKey:@"data"];
    NSLog(@"rParam:%@",rParam);
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,url] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"删除字典jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            [CommonFuntion showToast:@"删除成功" inView:self.view];
            [self sendCmdGetDataDictionary];
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self deleteDictionaryByIndex:index];
            };
            [comRequest loginInBackgroundLLC];
        }
        else {
            //获取失败
            NSString *desc = [jsonResponse safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"删除失败";
            }
            [CommonFuntion showToast:desc inView:self.view];
        }
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
    }];
}



#pragma mark - 没有数据时的view
-(void)notifyNoDataView{
    if (self.dataSource && [self.dataSource count] > 0) {
        [self clearViewNoData];
    }else{
        [self setViewNoData:@""];
    }
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
