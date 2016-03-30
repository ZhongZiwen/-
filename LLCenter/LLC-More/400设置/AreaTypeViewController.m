//
//  AreaTypeViewController.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-27.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//
///存储城市信息key
#define kLLCenter_AREA_CITY_DATA   @"llcenter_area_city_data"

#import "AreaTypeViewController.h"
#import "LLCenterUtility.h"
#import "CommonFunc.h"
#import "CommonStaticVar.h"
#import "CommonNoDataView.h"
#import "AreaTypeCell.h"

@interface AreaTypeViewController ()<UITableViewDataSource,UITableViewDelegate>{
    NSString *citySelectedIds;
}

@property(strong,nonatomic) UITableView *tableview;
@property(strong,nonatomic) NSMutableArray *dataSource;
@property(nonatomic,strong)NSArray *arrayDefaultArea;
@property (nonatomic, strong) CommonNoDataView *commonNoDataView;

@end

@implementation AreaTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"编辑地区策略";
    [super customBackButton];
    self.view.backgroundColor = COLOR_BG;
    [self initData];
    [self addNavBar];
//    [self readTestData];
    
    [self initCityData];
    [self initTableview];
    [self.tableview reloadData];
}

///初始化城市信息  先从缓存读取
-(void)initCityData{
    NSDictionary *allCityData = [self getLLCenterAreaData];
    if (allCityData && [allCityData objectForKey:@"provinceList"] && [allCityData objectForKey:@"cityList"]) {
        NSLog(@"存在缓存");
        NSArray *provinceList =  [allCityData objectForKey:@"provinceList"] ;
        NSArray *cityList =  [allCityData objectForKey:@"cityList"] ;
        
        [self initDataWithProvince:provinceList andCity:cityList];
    }else{
         [self initArea];
    }
    NSLog(@"self.dataSource:%@",self.dataSource);
}

#pragma mark - 初始化数据
-(void)initData{
    citySelectedIds = @"";
    self.dataSource = [[NSMutableArray alloc] init];
    if (self.areaStrategyData && [self.areaStrategyData objectForKey:@"areaCode"]) {
        NSString *areaCode = [self.areaStrategyData safeObjectForKey:@"areaCode"];
        self.arrayDefaultArea = [[areaCode stringByReplacingOccurrencesOfString:@"," withString:@";"] componentsSeparatedByString:@";"];
    }
     NSLog(@"self.areaStrategyData:%@",self.areaStrategyData);
    NSLog(@"self.arrayDefaultArea:%@",self.arrayDefaultArea);
}


-(void)initDataWithProvince:(NSArray *)provinceList andCity:(NSArray *)cityList{
    //provinceList
    //PROVINCEID = 3;
    //PROVINCENAME = "\U5b89\U5fbd\U7701";
    
    
    //cityList
//    AREAID = 1;
//    AREANAME = "\U5317\U4eac\U5e02";
//    "DISTRICT_NO" = 010;
//    "PROVINCE_ID" = 33;
    
    
    NSMutableArray *citysOfProvince;
    
    NSInteger countProvince = 0;
    NSInteger countCity = 0;
    if (provinceList) {
        countProvince = [provinceList count];
    }
    
    ///临时存放citys
    NSMutableArray *allCitys = [[NSMutableArray alloc] init];
    [allCitys addObjectsFromArray:cityList];
    
    NSInteger  province_id;
    NSString *province_name;
    NSMutableDictionary *itemProvinceCity ;
    ///遍历省份 对数据做组织
    for (int i=0; i<countProvince; i++) {
        province_id = [[[provinceList objectAtIndex:i] objectForKey:@"PROVINCEID"] integerValue];
        province_name = [[provinceList objectAtIndex:i] objectForKey:@"PROVINCENAME"];
        citysOfProvince = [[NSMutableArray alloc] init];
        if (allCitys) {
            countCity = [allCitys count];
        }
        for (int k=0; k<countCity; k++) {
            ///属于当前省份
            if (province_id == [[[allCitys objectAtIndex:k] objectForKey:@"PROVINCE_ID"] integerValue]) {
                [citysOfProvince addObject:[allCitys objectAtIndex:k]];
//                [allCitys removeObjectAtIndex:k];
//                countCity--;
            }
        }
        ///当前省份加入数组
        itemProvinceCity = [[NSMutableDictionary alloc] init];
        [itemProvinceCity setObject:[NSString stringWithFormat:@"%ti",province_id] forKey:@"provinceId"];
        [itemProvinceCity setObject:province_name forKey:@"provinceName"];
        [itemProvinceCity setObject:citysOfProvince forKey:@"areaList"];
        [self.dataSource addObject:itemProvinceCity];
    }
    
//    NSLog(@"self.dataSource:%@",self.dataSource);
    [self initAreaCheckTagsByDefaultData];
}


#pragma mark - 读取测试数据
-(void)readTestData{
    /*
     provinceList(省份列表
     provinceId 省份ID
     provinceName 省份名称
     areaList(地区列表
     areaId 地区区域
     areaName 地区名称)
     )
     */
    
    
    
    NSMutableDictionary *itemCity ;
    NSMutableArray *citys = [[NSMutableArray alloc] init];
    for (int i=0; i<10; i++) {
        itemCity = [[NSMutableDictionary alloc] init];
        [itemCity setObject:[NSString stringWithFormat:@"200%i",i] forKey:@"areaId"];
        [itemCity setObject:[NSString stringWithFormat:@"株洲%i",i] forKey:@"areaName"];
        [citys addObject:itemCity];
    }
    
    NSMutableDictionary *item ;
    
    for (int i=0; i<5; i++) {
        item =  [[NSMutableDictionary alloc] init];
        [item setObject:[NSString stringWithFormat:@"100%i",i] forKey:@"provinceId"];
        [item setObject:[NSString stringWithFormat:@"湖南省%i",i] forKey:@"provinceName"];
        [item setObject:citys forKey:@"areaList"];
        [self.dataSource addObject:item];
    }
    
//    [self initAreaCheckTags];
}




///初始化选中标记  全部NO   未使用
-(void)initAreaCheckTags{
    
    NSInteger count = 0;
    NSInteger countCity = 0;
    if (self.dataSource) {
        count = [self.dataSource count];
    }
    
    NSDictionary *itemProvince;
    NSDictionary *itemCity;
    NSMutableDictionary *mutableItemProvince;
    NSMutableDictionary *mutableItemCity;
    NSArray *arrayCity;
    NSMutableArray *arrayCityNew;
    for (int i=0; i<count; i++) {
        itemProvince = [self.dataSource objectAtIndex:i];

        ///省份
        mutableItemProvince = [NSMutableDictionary dictionaryWithDictionary:itemProvince];
        [mutableItemProvince setObject:@(NO) forKey:@"checked"];
        
        ///市级
        arrayCityNew = [[NSMutableArray alloc] init];
        countCity = 0;
        arrayCity = [itemProvince objectForKey:@"areaList"];
        if (arrayCity) {
            countCity = [arrayCity count];
        }
        for (int j=0; j<countCity; j++) {
            itemCity = [arrayCity objectAtIndex:j];
            mutableItemCity = [NSMutableDictionary dictionaryWithDictionary:itemCity];
            [mutableItemCity setObject:@(NO) forKey:@"checked"];
            [arrayCityNew addObject:mutableItemCity];
        }

        //修改数据源
        [mutableItemProvince setObject:arrayCityNew forKey:@"areaList"];
        [self.dataSource setObject: mutableItemProvince atIndexedSubscript:i];

    }
}


///根据初始数据设置默认选中项
-(void)initAreaCheckTagsByDefaultData{
    
    NSInteger count = 0;
    NSInteger countCity = 0;
    if (self.dataSource) {
        count = [self.dataSource count];
    }
    
    NSDictionary *itemProvince;
    NSDictionary *itemCity;
    NSMutableDictionary *mutableItemProvince;
    NSMutableDictionary *mutableItemCity;
    NSArray *arrayCity;
    NSMutableArray *arrayCityNew;
    ///标记省份下的城市是否全部选中
    BOOL isAllChecked = YES;
    for (int i=0; i<count; i++) {
        isAllChecked = YES;
        itemProvince = [self.dataSource objectAtIndex:i];
        
        ///省份
        mutableItemProvince = [NSMutableDictionary dictionaryWithDictionary:itemProvince];
        
        ///市级
        arrayCityNew = [[NSMutableArray alloc] init];
        countCity = 0;
        arrayCity = [itemProvince objectForKey:@"areaList"];
        if (arrayCity) {
            countCity = [arrayCity count];
        }
        for (int j=0; j<countCity; j++) {
            itemCity = [arrayCity objectAtIndex:j];
            mutableItemCity = [NSMutableDictionary dictionaryWithDictionary:itemCity];
            
            ///城市code是否相同 判断默认是否选中
            if ([self isDefaultCheckedCity:[itemCity objectForKey:@"DISTRICT_NO"]]) {
                [mutableItemCity setObject:@(YES) forKey:@"checked"];
            }else{
                [mutableItemCity setObject:@(NO) forKey:@"checked"];
                isAllChecked = NO;
            }
            [arrayCityNew addObject:mutableItemCity];
        }
        
        [mutableItemProvince setObject:@(isAllChecked) forKey:@"checked"];
        //修改数据源
        [mutableItemProvince setObject:arrayCityNew forKey:@"areaList"];
        [self.dataSource setObject: mutableItemProvince atIndexedSubscript:i];
        
    }
}

#pragma mark - 用默认数据做初始化操作

///根据城市code 判断是否默认为选中状态
-(BOOL)isDefaultCheckedCity:(NSString *)cityCode{
    NSInteger countDefault = 0;
    if (self.arrayDefaultArea) {
        countDefault = [self.arrayDefaultArea count];
    }
    BOOL isChecked = FALSE;
    ///设置选择项
    for(int i=0; !isChecked && i<countDefault; i++){
        
        if ([[self.arrayDefaultArea objectAtIndex:i] isEqualToString:cityCode]) {
            isChecked = TRUE;
        }
    }
    return isChecked;
}



#pragma mark - 选择城市事件
///更新checkbox选中状态
-(void)updateCheckBoxStatus:(NSInteger)section andRow:(NSInteger)row{
    
    NSInteger countCity = 0;
    
    NSMutableDictionary *mutableItemProvince;
    NSMutableDictionary *mutableItemCity;
    NSMutableArray *arrayCityNew = [[NSMutableArray alloc] init];

    NSDictionary *itemProvince = [self.dataSource objectAtIndex:section];
    NSArray *arrayCity = [itemProvince objectForKey:@"areaList"];
    NSDictionary *itemCity = [arrayCity objectAtIndex:row] ;
    
    mutableItemCity = [NSMutableDictionary dictionaryWithDictionary:itemCity];
    [mutableItemCity setObject:@(![[itemCity objectForKey:@"checked"] boolValue]) forKey:@"checked"];
    [arrayCityNew addObjectsFromArray:arrayCity];
    [arrayCityNew replaceObjectAtIndex:row withObject:mutableItemCity];
    
    
    BOOL isCheckedAll = YES;
    ////遍历  是否全选中
    if (arrayCityNew) {
        countCity = [arrayCityNew count];
    }
    for (int i=0; isCheckedAll && i<countCity; i++) {
        
        itemCity = [arrayCityNew objectAtIndex:i];
        
        if (![[itemCity objectForKey:@"checked"] boolValue]) {
            isCheckedAll = NO;
        }
    }
    
    ///省份
    mutableItemProvince = [NSMutableDictionary dictionaryWithDictionary:itemProvince];
    [mutableItemProvince setObject:@(isCheckedAll) forKey:@"checked"];
   
    //修改数据源
    [mutableItemProvince setObject:arrayCityNew forKey:@"areaList"];
    [self.dataSource setObject: mutableItemProvince atIndexedSubscript:section];
    
    [self.tableview reloadData];
    
}


#pragma mark - 选择省份事件
///更新checkbox选中状态
-(void)updateCheckBoxStatus:(NSInteger)section{
    
    NSInteger countCity = 0;
    
    NSMutableDictionary *mutableItemProvince;
    NSMutableDictionary *mutableItemCity;
    NSMutableArray *arrayCityNew;
    
    NSDictionary *itemProvince = [self.dataSource objectAtIndex:section];
    NSArray *arrayCity = [itemProvince objectForKey:@"areaList"];
    NSDictionary *itemCity  ;
    
    
    BOOL isChecked = [[itemProvince objectForKey:@"checked"] boolValue];
    
   
    ///市级
    arrayCityNew = [[NSMutableArray alloc] init];
    countCity = 0;
    arrayCity = [itemProvince objectForKey:@"areaList"];
    if (arrayCity) {
        countCity = [arrayCity count];
    }
    for (int j=0; j<countCity; j++) {
        itemCity = [arrayCity objectAtIndex:j];
        mutableItemCity = [NSMutableDictionary dictionaryWithDictionary:itemCity];
        [mutableItemCity setObject:@(!isChecked) forKey:@"checked"];
        [arrayCityNew addObject:mutableItemCity];
    }
    
    ///省份
    mutableItemProvince = [NSMutableDictionary dictionaryWithDictionary:itemProvince];
    [mutableItemProvince setObject:@(!isChecked) forKey:@"checked"];
    
    //修改数据源
    [mutableItemProvince setObject:arrayCityNew forKey:@"areaList"];
    [self.dataSource setObject: mutableItemProvince atIndexedSubscript:section];
    
    
    [self.tableview reloadData];
}


#pragma mark - Nav Bar
-(void)addNavBar{
    [super customBackButton];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonPress)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
}

#pragma mark-  完成事件
-(void)saveButtonPress {
    
    citySelectedIds = [self getCheckedCityIds];
    NSLog(@"citySelectedIds:%@",citySelectedIds);
    
    if (citySelectedIds == nil || [citySelectedIds isEqualToString:@""]) {
        [CommonFuntion showToast:@"至少选择一个地区" inView:self.view];
        return;
    }
    
    ///座席
    if ([self.navigationOrSit isEqualToString:@"sit"]) {
        [self selectedAreaOk:@""];
    }else{
        [self showEditViewForAearName];
    }
    
}

////选择地区完成
-(void)selectedAreaOk:(NSString *)areaName{
    
    ///需判断地区策略范围
    if ([self.flagOfNeedJudge isEqualToString:@"yes"]) {
        ///用城市code判断  所选城市是否在导航地区策略范围内
        NSArray *navAreaCode = nil;
        if (self.areaStrategyNavDic && [self.areaStrategyNavDic objectForKey:@"areaCode"]) {
            NSString *areaCode = [self.areaStrategyNavDic safeObjectForKey:@"areaCode"];
            if (![areaCode isEqualToString:@"1"]) {
                navAreaCode = [areaCode componentsSeparatedByString:@";"];
                
                NSPredicate * filterPredicate = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",navAreaCode];
                //过滤数组
                NSArray * reslutFilteredArray = [[citySelectedIds componentsSeparatedByString:@";"] filteredArrayUsingPredicate:filterPredicate];
                NSLog(@"Reslut Filtered Array = %@",reslutFilteredArray);
                
                if (reslutFilteredArray && [reslutFilteredArray count] > 0) {
                    
                    NSString *cityName = [self getCityNameByCode:[reslutFilteredArray objectAtIndex:0]];
                    
                    if ([reslutFilteredArray count] > 1) {
                        [CommonFuntion showToast:[NSString stringWithFormat:@"【%@等城市】不在分组地区策略范围内",cityName] inView:self.view];
                    }else{
                        [CommonFuntion showToast:[NSString stringWithFormat:@"【%@】不在分组地区策略范围内",cityName] inView:self.view];
                    }
                    
                    
                    return;
                }
            }
        }
    }
    
    
    if (self.SelectAreaDoneBlock) {
        self.SelectAreaDoneBlock(citySelectedIds,areaName);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 弹框 地区名称
-(void)showEditViewForAearName{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"地区名称" message:nil
                                                   delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert textFieldAtIndex:0].keyboardType = UIKeyboardTypeDefault;
    [alert textFieldAtIndex:0].placeholder = @"1-6个中文字符";
    [alert textFieldAtIndex:0].clearButtonMode = UITextFieldViewModeWhileEditing;
    [alert textFieldAtIndex:0].text = [self.areaStrategyData safeObjectForKey:@"areaName"];
    [alert setTag:1001];
    [alert show];
}

#pragma mark alertView的回调函数
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 1001)
    {
        if(buttonIndex == 0)
        {
            return;
        }
        else if(buttonIndex == 1)
        {
            if([[alertView textFieldAtIndex:0].text length] < 1)
            {
                [CommonFuntion showToast:@"地区名称不能为空" inView:self.view];
            }
            else
            {
                //修改等待时长
                //组装参数
                NSString *name = [[alertView textFieldAtIndex:0].text stringByReplacingOccurrencesOfString:@" " withString:@""];
                NSLog(@"name:%@",name);
                
                if (name.length  < 1 || name.length  > 6) {
                    [CommonFuntion showToast:@"地区名称为1-6个字符" inView:self.view];
                    return;
                }
                
                if ([CommonFunc isStringNullObject:name]) {
                    [CommonFuntion showToast:@"地区名称不能为null" inView:self.view];
                    return;
                }
                
                ///选择完成 跳转到前一页面
                [self selectedAreaOk:name];
            }
        }
    }
    
}





#pragma mark - 初始化tablview
-(void)initTableview{
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, DEVICE_BOUNDS_HEIGHT-64) style:UITableViewStylePlain];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.sectionFooterHeight = 0;
    [self.view addSubview:self.tableview];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableview setTableFooterView:v];
}

-(void)checkboxAction:(id)sender{
    UIButton *btn = (UIButton *)sender;
    [self updateCheckBoxStatus:btn.tag];
}

#pragma mark - tableview delegate
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headview =[[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, 50)];
    headview.backgroundColor = COLOR_BG;
    
    
    //    UIView *top = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, 20)];
    //    top.backgroundColor = COLOR_BG;
    
    
    UIButton *btnCheckBox = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCheckBox.frame = CGRectMake(20, 14, 22, 22);
    
    btnCheckBox.tag = section;
    [btnCheckBox addTarget:self action:@selector(checkboxAction:) forControlEvents:UIControlEventTouchUpInside];
    [headview addSubview:btnCheckBox];
    
    NSDictionary *item = [self.dataSource objectAtIndex:section];
    NSString *checkboxImg = @"";
    if ([[item objectForKey:@"checked"] boolValue]) {
        checkboxImg = @"login_checkbox_filled.png";
    }else{
        checkboxImg = @"login_checkbox_empty.png";
    }
    [btnCheckBox setBackgroundImage:[UIImage imageNamed:checkboxImg] forState:UIControlStateNormal];
    
    
    
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(55, 15, 200, 20)];
    labelTitle.textColor = [UIColor blackColor];
    labelTitle.font = [UIFont systemFontOfSize:17.0];
    
    NSString *name = [item safeObjectForKey:@"provinceName"];
    labelTitle.text = name;
    
    //    [headview addSubview:top];
    [headview addSubview:labelTitle];
    return headview;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.dataSource) {
        return [self.dataSource count];
    }
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([[self.dataSource objectAtIndex:section] objectForKey:@"areaList"]) {
        return [[[self.dataSource objectAtIndex:section] objectForKey:@"areaList"] count];
    }
    return 0;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ///座席
    AreaTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AreaTypeCellIdentify"];
    if (!cell)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"AreaTypeCell" owner:self options:nil];
        cell = (AreaTypeCell*)[array objectAtIndex:0];
        [cell awakeFromNib];

    }
    NSDictionary *item = [[[self.dataSource objectAtIndex:indexPath.section] objectForKey:@"areaList"] objectAtIndex:indexPath.row];
    
    [cell setCellDetails:item andIndexPath:indexPath];
    
    __weak typeof(self) weak_self = self;
    cell.CheckBoxBlock = ^(NSInteger index){
        NSLog(@"index section:%ti",indexPath.section);
        NSLog(@"index:%ti",index);
        [weak_self updateCheckBoxStatus:indexPath.section andRow:index];
    };
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma maerk - 获取选择城市
-(NSString *)getCheckedCityIds{
    NSInteger count = 0;
    NSInteger countCity = 0;
    NSArray *arrayCity;
    if(self.dataSource){
        count = [self.dataSource count];
    }
    NSMutableString *strIds = [[NSMutableString alloc] init];
    NSDictionary *item;
    for (int i=0; i<count; i++) {
        
        arrayCity = [[self.dataSource objectAtIndex:i] objectForKey:@"areaList"];
        countCity = 0;
        if (arrayCity) {
            countCity = [arrayCity count];
        }
        
        for (int k=0; k<countCity; k++) {
            item = [arrayCity objectAtIndex:k];
            ///选中的城市
            if ([[item objectForKey:@"checked"] boolValue]) {
                if ([strIds isEqualToString:@""]) {
                    [strIds appendString:[item safeObjectForKey:@"DISTRICT_NO"]];
                }else{
                    [strIds appendString:@";"];
                    [strIds appendString:[item safeObjectForKey:@"DISTRICT_NO"]];
                }
            }
        }
    }
    return strIds;
}



#pragma maerk - 获取选择城市
-(NSString *)getCityNameByCode:(NSString *)cityCode{
    NSInteger count = 0;
    NSInteger countCity = 0;
    NSArray *arrayCity;
    if(self.dataSource){
        count = [self.dataSource count];
    }
    NSDictionary *item;
    for (int i=0; i<count; i++) {
        
        arrayCity = [[self.dataSource objectAtIndex:i] objectForKey:@"areaList"];
        countCity = 0;
        if (arrayCity) {
            countCity = [arrayCity count];
        }
        
        for (int k=0; k<countCity; k++) {
            item = [arrayCity objectAtIndex:k];
            /// 城市名称
            if ([[item safeObjectForKey:@"DISTRICT_NO"] isEqualToString:cityCode]) {
                return [item objectForKey:@"AREANAME"];
            }
        }
    }
    return @"";
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


#pragma mark - 网络请求
///初始化地区
-(void)initArea{
    [self clearViewNoData];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:nil];
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_INIT_AREA_ACTION] params:params success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"地区jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            ///缓存城市信息
            [self setLLCenterAreaData:[jsonResponse objectForKey:@"resultMap"]];
            
            NSArray *provinceList =  [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"provinceList"] ;
            NSArray *cityList =  [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"cityList"] ;
            
            [self initDataWithProvince:provinceList andCity:cityList];
            
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self initArea];
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
        }
        [self.tableview reloadData];
        [self notifyNoDataView];
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
        [self.tableview reloadData];
        [self notifyNoDataView];
    }];
}

///使用原始数据初始化数据源
-(void)initDataSourceByDefaultData{
    NSDictionary *item;
    
}



#pragma mark - 城市信息存储
///存储地区策略涉及地区数据
-(void)setLLCenterAreaData:(NSDictionary *)areaData{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:areaData forKey:kLLCenter_AREA_CITY_DATA];
    [userDefaults synchronize];
    
}

///获取地区策略涉及地区数据
-(NSDictionary *)getLLCenterAreaData{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    return  [userDefaultes dictionaryForKey:kLLCenter_AREA_CITY_DATA];
}
@end
