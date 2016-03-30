//
//  ChargingViewController.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-12.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "ChargingViewController.h"
#import "LLCenterUtility.h"
#import "PNChartDelegate.h"
#import "PNChart.h"
#import "LLCenterUtility.h"
#import "CommonFunc.h"
#import "CustomNarTitleView.h"
#import "SmartConditionModel.h"
#import "ChargeRechargeCell.h"
#import "LLCenterYYYYMMPickerView.h"
#import "CommonNoDataView.h"
#import "CommonStaticVar.h"

#define WIDTH_CHART 50.0
#define HEIGHT_CHART_VIEW  DEVICE_BOUNDS_HEIGHT/2

#define COLOR_CHART_GREEN  [UIColor colorWithRed:39.0f/255 green:180.0f/255 blue:112.0f/255 alpha:1.0f]
#define COLOR_CHART_BLUE  [UIColor colorWithRed:60.0f/255 green:165.0f/255 blue:223.0f/255 alpha:1.0f]
#define COLOR_CHART_YELLOW  [UIColor colorWithRed:235.0f/255 green:194.0f/255 blue:61.0f/255 alpha:1.0f]
#define COLOR_CHART_GRAY  [UIColor colorWithRed:207.0f/255 green:210.0f/255 blue:211.0f/255 alpha:1.0f]

@interface ChargingViewController ()<PNChartDelegate,UITableViewDataSource,UITableViewDelegate>{
    UIScrollView *scrollview;
    UILabel * lablePieTitle;
    UIView *viewPieInfos;
    ///当前选择的类型
    NSString *curSelectType;
    ///当前默认选择的日期 年月
    NSString *curSelectDateYM;
    ///当前默认选择的日期 年
    NSString *curSelectDateY;
    ///当前默认选择的日期 天
    NSString *curSelectDateD;
}
@property (nonatomic) UILabel * lableBarTitle;
@property (nonatomic) PNLineChart * lineChart;
@property (nonatomic) PNBarChart * barChart;
@property (nonatomic) PNPieChart *pieChart;


///日期
@property(nonatomic,strong) NSMutableArray *arrDate;
///Y点值
@property(nonatomic,strong) NSMutableArray *arrYValye;
///折线图Y点值
@property(nonatomic,strong) NSMutableArray *arrYValyeLine;
///折线图X点值
@property(nonatomic,strong) NSMutableArray *arrXValyeLine;
///颜色值
@property(nonatomic,strong) NSMutableArray *arrColor;
///
@property(nonatomic,strong) NSMutableArray *arrPie;


@property (nonatomic, assign) NSInteger curIndex;
@property (nonatomic, strong) CustomNarTitleView *customTitleView;

@property (nonatomic, strong) NSMutableArray *dataSource;

///充值列表
@property(strong,nonatomic) UITableView *tableview;
@property (nonatomic, strong) CommonNoDataView *commonNoDataView;

@end

@implementation ChargingViewController

-(void)loadView{
    [super loadView];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"计费中心";
    self.view.backgroundColor = COLOR_BG;
    ///用来标记是否是否联络中心进入
    [CommonStaticVar setFromLLCenterView:@"llcenter"];
    
    [super customBackButton];
    [self addNavBar];
    /// 导航下拉菜单
    [self addNarMenu];
    ///初始化数据
    [self initChargeViewData];
    [self initChargeChartView];
    [self initRechargeTableView];
    [self showAndHideChartTableView];
     
    ///读取数据
//    [self readTestData];
    [self getChargingData];
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    ///用来标记是否是否联络中心进入
    [CommonStaticVar setFromLLCenterView:@""];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Nav Bar
-(void)addNavBar{
    
    UIButton *filterButton=[UIButton buttonWithType:UIButtonTypeCustom];
    filterButton.frame=CGRectMake(0, 0, 21, 20);
    [filterButton setBackgroundImage:[UIImage imageNamed:@"account_filter.png"] forState:UIControlStateNormal];
    [filterButton setBackgroundImage:[UIImage imageNamed:@"account_filter.png"] forState:UIControlStateHighlighted];
    [filterButton addTarget:self action:@selector(rightBarButtonAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *filterBarButton = [[UIBarButtonItem alloc] initWithCustomView:filterButton];
    [self.navigationItem setRightBarButtonItem:filterBarButton];
}


#pragma mark -
-(void)rightBarButtonAction{
    [self showDataPickerByFlag:_curIndex];
}


#pragma mark - 初始化图表数据
-(void)initChargeViewData{
    curSelectDateYM = [CommonFunc dateToString:[NSDate date] Format:@"yyyy-MM"];
    curSelectDateY = [CommonFunc dateToString:[NSDate date] Format:@"yyyy"];
    lablePieTitle = nil;
    self.dataSource = [[NSMutableArray alloc] init];
    self.arrDate = [[NSMutableArray alloc] init];
    self.arrXValyeLine = [[NSMutableArray alloc] init];
    self.arrYValye = [[NSMutableArray alloc] init];
    self.arrYValyeLine = [[NSMutableArray alloc] init];
    self.arrColor = [[NSMutableArray alloc] init];
    self.arrPie = [[NSMutableArray alloc] init];
}


#pragma mark - 初始化图表view
-(void)initChargeChartView{
    ///标题
    [self initBarChartTitleView];
    ///柱状
    [self initBarChartView];
    ///折线
    [self initLineChartView];
}


#pragma mark - 初始化列表view
-(void)initRechargeTableView{
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, DEVICE_BOUNDS_HEIGHT-64) style:UITableViewStyleGrouped];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.sectionFooterHeight = 0;
    self.tableview.separatorStyle = UITableViewCellAccessoryNone;
    [self.view addSubview:self.tableview];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableview setTableFooterView:v];
}


#pragma mark - 显示隐藏图表与列表view
-(void)showAndHideChartTableView{
    BOOL isHideChart = YES;
    BOOL isHideTable = YES;
    
    if (_curIndex == 0 || _curIndex == 2) {
        isHideChart = NO;
        isHideTable = YES;
    }else{
        isHideChart = YES;
        isHideTable = NO;
    }
    
    ///Chart View
    scrollview.hidden = YES;
    self.lableBarTitle.hidden = YES;
    self.lineChart.hidden = YES;
    self.barChart.hidden = YES;
    
    lablePieTitle.hidden = YES;
    viewPieInfos.hidden = YES;
    self.pieChart.hidden = YES;
    
    ///Table View
    self.tableview.hidden = isHideTable;
}


#pragma mark - 读取测试数据
-(void)readTestData{
    [self.dataSource removeAllObjects];
    
    if (_curIndex == 0) {
        id jsondata = [CommonFunc readJsonFile:@"charge-xf"];
        [self.dataSource addObjectsFromArray:[[jsondata objectForKey:@"resultMap"] objectForKey:@"data"]];
        NSLog(@"self.dataSource:%@",self.dataSource);
    }else if (_curIndex == 2){
        id jsondata = [CommonFunc readJsonFile:@"charge-400xf"];
        [self.dataSource addObjectsFromArray:[[jsondata objectForKey:@"resultMap"] objectForKey:@"data"]];
        NSLog(@"self.dataSource:%@",self.dataSource);
    }else if (_curIndex == 1 || _curIndex == 3 ){
        id jsondata = [CommonFunc readJsonFile:@"charge-cz"];
        
        [self transFromData:[[jsondata objectForKey:@"resultMap"] objectForKey:@"data"]];
        
//        [self.dataSource addObjectsFromArray:[[jsondata objectForKey:@"resultMap"] objectForKey:@"data"]];
        NSLog(@"self.dataSource:%@",self.dataSource);
    }
    ///刷新UI
    if (_curIndex == 0 || _curIndex == 2) {
        [scrollview setContentOffset:CGPointMake(0,0) animated:YES];
        [self notifyChartViewData];
    }
    else if (_curIndex == 1 || _curIndex == 3 ){
        [self.tableview reloadData];
    }
}




#pragma mark - 转换充值数据格式
-(void)transFromData:(NSArray *)dataArray{
    NSInteger countData = 0;
    if (dataArray) {
        countData = [dataArray count];
    }
    
    NSDictionary *item;
    NSDictionary *itemOther;
    NSMutableArray *keyGroup = [[NSMutableArray alloc] init];
    NSMutableArray *arrayGroup;
    NSMutableDictionary *dataItemT;
    NSString *keyDate = @"";
    
    BOOL isContinue = FALSE;
    for (int i=0; i<countData; i++) {
        item = [dataArray objectAtIndex:i];
        keyDate = [item safeObjectForKey:@"rechargedate"];
        
        isContinue = FALSE;
        ///不包含当前日期
        if (![keyGroup containsObject:keyDate]) {
            arrayGroup = [[NSMutableArray alloc] init];
            [arrayGroup addObject:item];
            [keyGroup addObject:keyDate];
            isContinue = TRUE;
        }
        
        ///遍历其后的元素
        for(int j=i+1;isContinue && j<countData;j++){
            itemOther = [dataArray objectAtIndex:j];
            if ([keyDate isEqualToString:[itemOther safeObjectForKey:@"rechargedate"]]) {
                [arrayGroup addObject:itemOther];
            }
        }
        
        ///添加相同元素到数组
        if (isContinue && arrayGroup && [arrayGroup count] > 0) {
            dataItemT = [[NSMutableDictionary alloc] init];
            [dataItemT setObject:arrayGroup forKey:@"data"];
            [dataItemT setObject:[self getTitleByStringDate:keyDate] forKey:@"date"];
            
            [self.dataSource addObject:dataItemT];
        }
    }
}


#pragma mark - Title 菜单
-(void)addNarMenu{
    
    _curIndex = 0;
    
    NSMutableArray *arraySour = [[NSMutableArray alloc] init];
    SmartConditionModel *model1 = [[SmartConditionModel alloc] init];
    model1.name = @"联络中心-消费";
    [arraySour addObject:model1];
    
    SmartConditionModel *model2 = [[SmartConditionModel alloc] init];
    model2.name = @"联络中心-充值";
    [arraySour addObject:model2];
    
    SmartConditionModel *model3 = [[SmartConditionModel alloc] init];
    model3.name = @"400套餐-消费";
    [arraySour addObject:model3];
    
    SmartConditionModel *model4 = [[SmartConditionModel alloc] init];
    model4.name = @"400套餐-充值";
    [arraySour addObject:model4];
    
    __weak typeof(self) weak_self = self;
    self.customTitleView.sourceArray = arraySour;
    self.customTitleView.index = 0;
    self.customTitleView.valueBlock = ^(NSInteger index) {
        
        weak_self.curIndex = index;
        curSelectDateYM = [CommonFunc dateToString:[NSDate date] Format:@"yyyy-MM"];
        curSelectDateY = [CommonFunc dateToString:[NSDate date] Format:@"yyyy"];
        ///读取数据  刷新UI
        [weak_self showAndHideChartTableView];
//        [weak_self readTestData];
        [weak_self getChargingData];
    };
    self.navigationItem.titleView = self.customTitleView;
}


- (CustomNarTitleView*)customTitleView {
    if (!_customTitleView) {
        _customTitleView = [[CustomNarTitleView alloc] init];
        _customTitleView.superViewController = self;
    }
    return _customTitleView;
}


#pragma mark - init TitleView

-(void)initBarChartTitleView{
    self.lableBarTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, 40)];
    self.lableBarTitle.font = [UIFont systemFontOfSize:17.0];
    self.lableBarTitle.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.lableBarTitle];
}

#pragma mark - init barchart
-(void)initBarChartView{
    NSInteger count = [self.arrDate count];
    static NSNumberFormatter *barChartFormatter;
    if (!barChartFormatter){
        barChartFormatter = [[NSNumberFormatter alloc] init];
        barChartFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
        barChartFormatter.allowsFloats = NO;
        barChartFormatter.maximumFractionDigits = 0;
    }
    
    scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 40.0, SCREEN_WIDTH, HEIGHT_CHART_VIEW-40.0)];
    scrollview.contentSize = CGSizeMake(WIDTH_CHART*count, 0);
    
    self.barChart = [[PNBarChart alloc] initWithFrame:CGRectMake(0, 0, WIDTH_CHART*count, HEIGHT_CHART_VIEW-40.0-20)];
    
    
//   self.barChart.showLabel = NO;
    self.barChart.backgroundColor = [UIColor clearColor];
    self.barChart.barBackgroundColor = [UIColor clearColor];
    self.barChart.yLabelFormatter = ^(CGFloat yValue){
        return [barChartFormatter stringFromNumber:[NSNumber numberWithFloat:yValue]];
    };
    
    self.barChart.barWidth = WIDTH_CHART-1;
    self.barChart.yChartLabelWidth = 20.0;
    self.barChart.chartMargin = 0.0;
    self.barChart.labelMarginTop = 5.0;
    self.barChart.showChartBorder = YES;
    self.barChart.delegate = self;
    
    [self.barChart setXLabels:self.arrDate];
    [self.barChart setYValues:self.arrYValye];
//    [self.barChart setStrokeColors:self.arrColor];
    
    [self.barChart strokeChart];
    [self.barChart hideXLable];
    [self.barChart hideYLable];
    
    
    [scrollview addSubview:self.barChart];
    [self.view addSubview:scrollview];
}



#pragma mark - init linechart
-(void)initLineChartView{
    
    NSInteger count = [self.arrXValyeLine count];
//    scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 100.0, SCREEN_WIDTH, 200.0)];
//    scrollview.contentSize = CGSizeMake(WIDTH_CHART*count, 0);
    
    self.lineChart = [[PNLineChart alloc] initWithFrame:CGRectMake(-50, 0, WIDTH_CHART*(count+1), HEIGHT_CHART_VIEW-40.0-20)];
    self.lineChart.yLabelFormat = @"%1.1f";
    self.lineChart.backgroundColor = [UIColor clearColor];
    
    self.lineChart.showCoordinateAxis = NO;
    self.lineChart.chartCavanWidth = WIDTH_CHART*count;
    [self.lineChart setXLabels:self.arrXValyeLine];
    
    //Use yFixedValueMax and yFixedValueMin to Fix the Max and Min Y Value
    //Only if you needed
    self.lineChart.yFixedValueMax = 300.0;
    self.lineChart.yFixedValueMin = 0.0;
    
   
    // Line Chart
    NSArray * data01Array = self.arrYValyeLine;
    PNLineChartData *data01 = [PNLineChartData new];
    data01.dataTitle = @"Alpha";
    data01.color = PNBrown;
    data01.alpha = 0.3f;
    data01.itemCount = data01Array.count;
    data01.inflexionPointStyle = PNLineChartPointStyleTriangle;
    data01.getData = ^(NSUInteger index) {
        CGFloat yValue = [data01Array[index] floatValue];
        return [PNLineChartDataItem dataItemWithY:yValue];
    };
    
    self.lineChart.chartData = @[data01];
    [self.lineChart strokeChart];
    self.lineChart.delegate = self;
    
    [self.lineChart hideXLable];
    [self.lineChart hideYLable];
    ///添加linechart
    [scrollview addSubview:self.lineChart];
}


#pragma mark - init piechart
-(void)initPieChartView{
    
    NSInteger pieChartWidth = 0;
    if (DEVICE_BOUNDS_WIDTH > HEIGHT_CHART_VIEW) {
        pieChartWidth = (HEIGHT_CHART_VIEW - 120);
    }else{
        pieChartWidth = DEVICE_BOUNDS_WIDTH-120;
    }
    
    self.pieChart = [[PNPieChart alloc] initWithFrame:CGRectMake(20, HEIGHT_CHART_VIEW+20, pieChartWidth, pieChartWidth) items:self.arrPie];
    self.pieChart.descriptionTextColor = [UIColor whiteColor];
    self.pieChart.descriptionTextFont  = [UIFont fontWithName:@"Avenir-Medium" size:11.0];
    self.pieChart.descriptionTextShadowColor = [UIColor clearColor];
    self.pieChart.showAbsoluteValues = NO;
    self.pieChart.showOnlyValues = NO;
    
    [self.pieChart strokeChart];
    
    
    [self.view addSubview:self.pieChart];
    
    if (self.arrPie && [self.arrPie count] > 0) {
        viewPieInfos = [self createPieChartInfosView:pieChartWidth+80];
        viewPieInfos.frame = CGRectMake(pieChartWidth+80, HEIGHT_CHART_VIEW+(pieChartWidth+40-viewPieInfos.frame.size.height)/2, viewPieInfos.frame.size.width, viewPieInfos.frame.size.height);
        [self.view addSubview:viewPieInfos];
    }
    else{
    }
}


#pragma mark - 饼状图右侧信息
-(UIView *)createPieChartInfosView:(NSInteger)xPoint{
    
    NSInteger width =  DEVICE_BOUNDS_WIDTH-xPoint;
    NSInteger yPoint = 0;
    UIView *viewDetails = [[UIView alloc] initWithFrame:CGRectMake(xPoint, yPoint, width, HEIGHT_CHART_VIEW)];
    
    UILabel *lableDW = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, width-10, 20)];
    lableDW.font = [UIFont systemFontOfSize:14.0];
    yPoint += 30;
    
    ///item 1
    UIImageView *icon1 = [[UIImageView alloc] initWithFrame:CGRectMake(5, yPoint+5, 10, 10)];
    icon1.image = [CommonFunc createImageWithColor:COLOR_CHART_YELLOW];
    
    UILabel *lable1 = [[UILabel alloc] initWithFrame:CGRectMake(20, yPoint, width-20, 20)];
    lable1.font = [UIFont systemFontOfSize:14.0];
    yPoint += 30;
    
    
    ///item 2
    UIImageView *icon2 = [[UIImageView alloc] initWithFrame:CGRectMake(5, yPoint+5, 10, 10)];
    icon2.image = [CommonFunc createImageWithColor:COLOR_CHART_GRAY];
    
    UILabel *lable2 = [[UILabel alloc] initWithFrame:CGRectMake(20, yPoint, width-20, 20)];
    lable2.font = [UIFont systemFontOfSize:14.0];
    yPoint += 30;
    
    
    ///item 3
    UIImageView *icon3 = [[UIImageView alloc] initWithFrame:CGRectMake(5, yPoint+5, 10, 10)];
    if (_curIndex == 0) {
        icon3.image = [CommonFunc createImageWithColor:COLOR_CHART_BLUE];
    }else{
        icon3.image = [CommonFunc createImageWithColor:COLOR_CHART_GREEN];
    }
    
    
    UILabel *lable3 = [[UILabel alloc] initWithFrame:CGRectMake(20, yPoint, width-20, 20)];
    lable3.font = [UIFont systemFontOfSize:14.0];
    
    if (_curIndex == 0) {
        lableDW.text = @"单位: 元";
        lable1.text = @"邮件";
        lable2.text = @"传真";
        lable3.text = @"外呼";
        
        yPoint += 30;
        ///item 4
        UIImageView *icon4 = [[UIImageView alloc] initWithFrame:CGRectMake(5, yPoint+5, 10, 10)];
        icon4.image = [CommonFunc createImageWithColor:COLOR_CHART_GREEN];
        
        UILabel *lable4 = [[UILabel alloc] initWithFrame:CGRectMake(20, yPoint, width-20, 20)];
        lable4.font = [UIFont systemFontOfSize:14.0];
        lable4.text = @"短信";
        
        [viewDetails addSubview:icon4];
        [viewDetails addSubview:lable4];
        
    }else if (_curIndex == 2){
        
        lableDW.text = @"单位: 分钟";
        lable1.text = @"已接来电";
        lable2.text = @"未接来电";
        lable3.text = @"语音信箱";
        
    }
    

    [viewDetails addSubview:lableDW];
    [viewDetails addSubview:icon1];
    [viewDetails addSubview:lable1];
    [viewDetails addSubview:icon2];
    [viewDetails addSubview:lable2];
    [viewDetails addSubview:icon3];
    [viewDetails addSubview:lable3];
    
    
    viewDetails.frame = CGRectMake(xPoint, 0, width, yPoint);
    
    return viewDetails;
}


#pragma mark - 柱状点击事件
- (void)userClickedOnBarAtIndex:(NSInteger)barIndex
{
//    [self changeBarChartColorSelected:barIndex];
//    if (self.dataSource && barIndex < [self.dataSource count]) {
//        [self notifyPieChartView:[self.dataSource objectAtIndex:barIndex]];
//    }
}

#pragma mark - 折线点击事件
- (void)userClickedOnLineKeyPoint:(CGPoint)point lineIndex:(NSInteger)lineIndex pointIndex:(NSInteger)pointIndex{
    NSLog(@"Click Key on line %f, %f line index is %d and point index is %d",point.x, point.y,(int)lineIndex, (int)pointIndex);
    [self changeBarChartColorSelected:pointIndex];
    if (self.dataSource && pointIndex < [self.dataSource count]) {
        [self notifyPieChartView:[self.dataSource objectAtIndex:pointIndex]];
    }
    
}

- (void)userClickedOnLinePoint:(CGPoint)point lineIndex:(NSInteger)lineIndex{
    NSLog(@"Click on line %f, %f, line index is %d",point.x, point.y, (int)lineIndex);
}


-(void)changeBarChartColorSelected:(NSInteger)barIndex{
    NSLog(@"changeBarChartColorSelected barIndex:%ti",barIndex);
    PNBar * barTmp ;
    for (int i=0; i<self.barChart.bars.count; i++) {
        barTmp = [self.barChart.bars objectAtIndex:i];
        if (i == barIndex) {
            barTmp.barColor = PNLightGrey;
        }else{
            barTmp.barColor = PNGrey;
        }
    }
    [self.barChart updateBar];
}





#pragma mark - 刷新数据

///获取折线图Y轴最大值
-(float)getMaxLineChartViewYValue{
    
//    NSComparator cmptr = ^(id obj1, id obj2){
//        if ([obj1 integerValue] > [obj2 integerValue]) {
//            return (NSComparisonResult)NSOrderedDescending;
//        }
//        
//        if ([obj1 integerValue] < [obj2 integerValue]) {
//            return (NSComparisonResult)NSOrderedAscending;
//        }
//        return (NSComparisonResult)NSOrderedSame;
//    };
//    
//    NSArray *array = [self.dataSource sortedArrayUsingComparator:cmptr];
//    NSString *max = [array lastObject];
    
    
    NSInteger countData = 0;
    if (self.dataSource) {
        countData = [self.dataSource count];
    }
    
    float maxYValue = 0;
    NSDictionary *item;
    NSString *valueKey = @"";
    ///联络中心消费
    if (_curIndex == 0) {
        valueKey = @"totalcost";
    }else if (_curIndex == 2){
        valueKey = @"totalduration";
    }
    
    for (int i=0; i<countData; i++) {
        item = [self.dataSource objectAtIndex:i];
        
        if (i==0) {
            maxYValue = [[item safeObjectForKey:valueKey] floatValue];
        }else{
            if (maxYValue < [[item safeObjectForKey:valueKey] floatValue]) {
                maxYValue = [[item safeObjectForKey:valueKey] floatValue];
            }
        }
    }
    NSLog(@"maxYValue:%f",maxYValue);
    return maxYValue;
}

///刷新图表数据
-(void)notifyChartViewData{
    
    BOOL isHide = NO;
    if (self.dataSource == nil || [self.dataSource count] == 0) {
        isHide = YES;
    }

    ///根据返回数据  控制图表显示与隐藏
    scrollview.hidden = isHide;
    self.lableBarTitle.hidden = isHide;
    self.lineChart.hidden = isHide;
    self.barChart.hidden = isHide;
    
    lablePieTitle.hidden = isHide;
    viewPieInfos.hidden = isHide;
    self.pieChart.hidden = isHide;
    
    NSLog(@"curSelectDateYM:%@",curSelectDateYM);
    self.lableBarTitle.text = [NSString stringWithFormat:@"%@年%@月", [curSelectDateYM substringToIndex:4],[curSelectDateYM substringFromIndex:5]];
   
    
    NSInteger countData = 0;
    if (self.dataSource) {
        countData = [self.dataSource count];
    }

    [self.arrXValyeLine removeAllObjects];
    [self.arrDate removeAllObjects];
    [self.arrYValye removeAllObjects];
    [self.arrYValyeLine removeAllObjects];
    
    ///柱状 -  X轴
    for (int i=0; i<countData; i++) {
        NSString *dateTitle = [[self.dataSource objectAtIndex:i] safeObjectForKey:@"date"];
        if (dateTitle && dateTitle.length > 5) {
            dateTitle = [dateTitle substringFromIndex:5];
        }
        [self.arrXValyeLine addObject:dateTitle];
        [self.arrDate addObject:dateTitle];
    }
    
    for (int i=0; i<countData; i++) {
        [self.arrYValye addObject:@20.00];
    }
    
    
    ///如果数据不够一屏幕的话添加
    if (countData < 8) {
        for(NSInteger i=countData; i<8;i++){
            [self.arrDate addObject:@""];
            [self.arrYValye addObject:@20.00];
        }
    }
    
    
    ///折线图数值
    ///所有值减少60/2
    float total = 0;
   
    for (int i=0; i<countData; i++) {
        ///联络中心消费
        if (_curIndex == 0) {
            total = [[[self.dataSource objectAtIndex:i] safeObjectForKey:@"totalcost"] floatValue];
        }else if (_curIndex == 2){
            ///400消费
            total = [[[self.dataSource objectAtIndex:i] safeObjectForKey:@"totalduration"] floatValue];
        }
        
        if (total == 0) {
            total = 0.01;
        }
        
        [self.arrYValyeLine addObject:[NSNumber numberWithFloat:total]];
    }
    
    
//    self.dataSource
    
    [scrollview setContentOffset:CGPointMake(0,0) animated:YES];
    
    ///刷新柱状
    [self notifyBarChartView];
    ///刷新折线图
    [self notifyLineChartView];
//    ///刷新饼状图
    if (countData > 0) {
        NSLog(@"刷新饼状图");
        [self notifyPieChartView:[self.dataSource objectAtIndex:0]];
    }
}


///刷新柱状
-(void)notifyBarChartView{

    NSInteger count = [self.arrDate count];

    scrollview.contentSize = CGSizeMake(WIDTH_CHART*count, 0);
    self.barChart.frame = CGRectMake(0, 0, WIDTH_CHART*count, HEIGHT_CHART_VIEW-40.0-20);
    self.barChart.barWidth = WIDTH_CHART-1;
    self.barChart.delegate = self;
    
    [self.barChart setXLabels:self.arrDate];
    [self.barChart setYValues:self.arrYValye];
//    [self.barChart setStrokeColors:self.arrColor];
    
//    [self.barChart hideXLable];
    [self.barChart hideYLable];
    [self.barChart strokeChart];
    
    ///默认选择第一个
    [self changeBarChartColorSelected:0];
}

///刷新折线图
-(void)notifyLineChartView{
    
    
    NSInteger count = [self.arrYValyeLine count];
    NSLog(@"self.arrYValyeLine:%@",self.arrYValyeLine);
    self.lineChart.frame = CGRectMake(-50, 30, WIDTH_CHART*(count+1), HEIGHT_CHART_VIEW-40.0-20);
    self.lineChart.chartCavanWidth = WIDTH_CHART*count;
    [self.lineChart.pathPoints removeAllObjects];
    
    [self.lineChart setXLabels:self.arrXValyeLine];
    
    //Use yFixedValueMax and yFixedValueMin to Fix the Max and Min Y Value
    //Only if you needed
    self.lineChart.yFixedValueMax = [self getMaxLineChartViewYValue];
    self.lineChart.yFixedValueMin = 0.0;
    
    
    // Line Chart
    NSArray * data01Array = self.arrYValyeLine;
    PNLineChartData *data01 = [PNLineChartData new];
    data01.dataTitle = @"Alpha";
    data01.color = PNDeepGreen;
    data01.alpha = 0.9f;
    data01.itemCount = data01Array.count;
    data01.inflexionPointStyle = PNLineChartPointStyleTriangle;
    data01.getData = ^(NSUInteger index) {
        CGFloat yValue = [data01Array[index] floatValue];
        return [PNLineChartDataItem dataItemWithY:yValue];
    };
    
    self.lineChart.chartData = @[data01];
    [self.lineChart strokeChart];
//    [self.lineChart updateChartData:@[data01]];
    
    [self.lineChart hideXLable];
    [self.lineChart hideYLable];
}


///刷新饼状图
-(void)notifyPieChartView:(NSDictionary *)item{
    
    if (lablePieTitle == nil) {
        lablePieTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, HEIGHT_CHART_VIEW, DEVICE_BOUNDS_WIDTH, 20)];
        lablePieTitle.font = [UIFont systemFontOfSize:16.0];
        lablePieTitle.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:lablePieTitle];
    }
    
    ///截取
    NSString *pieTitle = [item safeObjectForKey:@"date"];
    if (pieTitle && pieTitle.length > 5) {
        pieTitle = [pieTitle substringFromIndex:5];
    }
    //11-09
    lablePieTitle.text = [NSString stringWithFormat:@"%@月%@日", [pieTitle substringToIndex:2],[pieTitle substringFromIndex:3]];
    
    [viewPieInfos removeFromSuperview];
    [self.pieChart removeFromSuperview];
    ///移除旧view
    if (viewPieInfos) {
        [viewPieInfos removeFromSuperview];
    }
    
    [self.arrPie removeAllObjects];
    ///饼状数据
    ///联络中心消费
    float value1 = 0;
    float value2 = 0;
    float value3 = 0;
    float value4 = 0;
    NSArray *itemsPie;
    if (_curIndex == 0) {
//
//        emailcost(邮件费用)
//        faxcost(传真费用)
///       outcallcost(外呼费用)
//        smscost(短信费用)
        value1 = [[item safeObjectForKey:@"emailcost"] floatValue];
        value2 = [[item safeObjectForKey:@"faxcost"] floatValue];
        value3 = [[item safeObjectForKey:@"outcallcost"] floatValue];
        value4 = [[item safeObjectForKey:@"smscost"] floatValue];
        
        itemsPie = @[[PNPieChartDataItem dataItemWithValue:value1 color:COLOR_CHART_YELLOW description:@""],
                     [PNPieChartDataItem dataItemWithValue:value2 color:COLOR_CHART_GRAY description:@""],
                     [PNPieChartDataItem dataItemWithValue:value3 color:COLOR_CHART_BLUE description:@""],
                     [PNPieChartDataItem dataItemWithValue:value4 color:COLOR_CHART_GREEN description:@""],
                     ];
        
    }else if (_curIndex == 2){
//        receiveduration(已接来电)
//        missduration(未接来电)
//        voiceduration(语音信箱)
        ///400消费
        value1 = [[item safeObjectForKey:@"receiveduration"] floatValue];
        value2 = [[item safeObjectForKey:@"missduration"] floatValue];
        value3 = [[item safeObjectForKey:@"voiceduration"] floatValue];
       
        
        itemsPie = @[[PNPieChartDataItem dataItemWithValue:value1 color:COLOR_CHART_YELLOW description:@""],
                     [PNPieChartDataItem dataItemWithValue:value2 color:COLOR_CHART_GRAY description:@""],
                     [PNPieChartDataItem dataItemWithValue:value3 color:COLOR_CHART_GREEN description:@""]
                     ];
    }
    
    
    [self.arrPie addObjectsFromArray:itemsPie];
    
    
    NSInteger pieChartWidth = 0;
    if (DEVICE_BOUNDS_WIDTH > HEIGHT_CHART_VIEW) {
        pieChartWidth = (HEIGHT_CHART_VIEW - 120);
    }else{
        pieChartWidth = DEVICE_BOUNDS_WIDTH-120;
    }
    
    NSLog(@"DEVICE_BOUNDS_WIDTH:%f",DEVICE_BOUNDS_WIDTH);
    NSLog(@"HEIGHT_CHART_VIEW:%f",HEIGHT_CHART_VIEW);
    NSLog(@"pieChartWidth:%ti",pieChartWidth);
    
    self.pieChart = [[PNPieChart alloc] initWithFrame:CGRectMake(20, HEIGHT_CHART_VIEW+20, pieChartWidth, pieChartWidth) items:self.arrPie];

    self.pieChart.descriptionTextColor = [UIColor whiteColor];
    self.pieChart.descriptionTextFont  = [UIFont fontWithName:@"Avenir-Medium" size:11.0];
    self.pieChart.descriptionTextShadowColor = [UIColor clearColor];
    self.pieChart.showAbsoluteValues = YES;
    self.pieChart.showOnlyValues = NO;
    if (_curIndex == 0) {
        self.pieChart.isAmtData = YES;
    }else{
        self.pieChart.isAmtData = NO;
    }
    
    [self.pieChart strokeChart];
    
    
    [self.view addSubview:self.pieChart];
    
    
    if (self.arrPie && [self.arrPie count] > 0) {
        viewPieInfos = [self createPieChartInfosView:pieChartWidth+60];
        viewPieInfos.frame = CGRectMake(pieChartWidth+60, HEIGHT_CHART_VIEW+(pieChartWidth+40-viewPieInfos.frame.size.height)/2, viewPieInfos.frame.size.width, viewPieInfos.frame.size.height);
        [self.view addSubview:viewPieInfos];
        NSLog(@"viewInfos ypoint:%f",HEIGHT_CHART_VIEW+(HEIGHT_CHART_VIEW-viewPieInfos.frame.size.height)/2);
        NSLog(@"viewInfos height:%f",viewPieInfos.frame.size.height);
    }
    
}


#pragma mark - tableview delegate
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headview =[[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, 40)];
    headview.backgroundColor = COLOR_BG;
    
    NSString *title = [[self.dataSource objectAtIndex:section] objectForKey:@"date"];
    CGSize sizeTitle = [CommonFunc getSizeOfContents:title Font:[UIFont systemFontOfSize:15.0] withWidth:200 withHeight:20];
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(5, 10, sizeTitle.width+5, 30)];
    icon.contentMode = UIViewContentModeScaleToFill;
    icon.image = [CommonFunc createImageWithColor:PNLightGrey];
    icon.layer.cornerRadius = 6;
    icon.layer.masksToBounds = YES;
    
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(5, 15, sizeTitle.width+5, 20)];
    labelTitle.text = title;
    labelTitle.font = [UIFont systemFontOfSize:15.0] ;
    labelTitle.textAlignment = NSTextAlignmentCenter;
    
    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(15, 40, 3, 10)];
    line.contentMode = UIViewContentModeScaleToFill;
    line.image = [CommonFunc createImageWithColor:PNLightGrey];
    line.layer.masksToBounds = YES;
    
    if (section != 0) {
        UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(15, 0, 3, 10)];
        line.contentMode = UIViewContentModeScaleToFill;
        line.image = [CommonFunc createImageWithColor:PNLightGrey];
        line.layer.masksToBounds = YES;
        [headview addSubview:line];
    }
    
    
    [headview addSubview:icon];
    [headview addSubview:labelTitle];
    [headview addSubview:line];
    
    return headview;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.dataSource) {
        return [self.dataSource count];
    }
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[[self.dataSource objectAtIndex:section] objectForKey:@"data"] count];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ChargeRechargeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChargeRechargeCellIdentify"];
    if (!cell)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"ChargeRechargeCell" owner:self options:nil];
        cell = (ChargeRechargeCell*)[array objectAtIndex:0];
        [cell awakeFromNib];
    }
    [cell setCellDetails:[[[self.dataSource objectAtIndex:indexPath.section] objectForKey:@"data"] objectAtIndex:indexPath.row]];
    
    if (indexPath.section == [self.dataSource count]-1  && indexPath.row == [[[self.dataSource objectAtIndex:indexPath.section] objectForKey:@"data"] count]-1) {
        cell.imgLineBottom.hidden = YES;
        NSLog(@"indexPath:%@",indexPath);
    }else{
        cell.imgLineBottom.hidden = NO;
    }
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


#pragma mark - 日期弹框
///
-(void)showDataPickerByFlag:(NSInteger)flag{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    ///开始日期
    __weak typeof(self) weak_self = self;
    
    NSNumber *maxYear = @([[CommonFunc dateToString:[NSDate date] Format:@"yyyy"] integerValue]);
    NSNumber *minYear = @2014;
    
    NSArray *arrYears = nil;
    NSInteger type = 1;
    ///消费
    if (flag == 0 || flag == 2) {
        type = 1;
    }else{
        ///充值
        type = 2;
        arrYears = [self getValidYears];
    }
    
    LLCenterYYYYMMPickerView *llsheet = [[LLCenterYYYYMMPickerView alloc]initWithMaxYear:maxYear andMinYear:minYear andTitle:@"请选择日期" andData:arrYears andType:type];
    llsheet.selectedDateBlock = ^(NSString *datetime){

        NSString *selectedDate = datetime;
        if (selectedDate == nil) {
            ///消费
            if (flag == 0 || flag == 2) {
                curSelectDateYM = [CommonFunc dateToString:[NSDate date] Format:@"yyyy-MM"];
            }else{
                curSelectDateY = [CommonFunc dateToString:[NSDate date] Format:@"yyyy"];
            }
        }else{
            if (flag == 0 || flag == 2) {
                curSelectDateYM = selectedDate;
            }else{
                curSelectDateY = selectedDate;
            }
        }
        NSLog(@"-----selectedDate:%@",selectedDate);
        
        ///发送请求
        [weak_self getChargingData];
    };
    [llsheet showInView:nil];
}


///获取有效年份
-(NSArray *)getValidYears{
    NSInteger maxYear = [[CommonFunc dateToString:[NSDate date] Format:@"yyyy"] integerValue];
    NSMutableArray *arrYears = [[NSMutableArray alloc] init];
    
    for (NSInteger i=maxYear; i>2013; i--) {
        [arrYears addObject:[NSString stringWithFormat:@"%ti",i]];
    }
    return arrYears;
}


#pragma mark - 根据年月获取其对应月份的天数
-(NSInteger)getMonthDaysByDate:(NSString *)strDate{
    NSDate *desDate =  [CommonFunc stringToDate:strDate Format:@"yyyy-MM"];
    NSCalendar *c = [NSCalendar currentCalendar];
    NSRange days = [c rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:desDate];
    NSLog(@"days:%ti",days.length);
    return days.length;
}

#pragma mark - string 日期比较

-(NSString *)getTitleByStringDate:(NSString *)strDate{
    
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate *today = [[NSDate alloc] init];
    NSDate *yesterday;
    
    yesterday = [today dateByAddingTimeInterval: -secondsPerDay];
    
    // 10 first characters of description is the calendar date:
    NSString * todayString = [[today description] substringToIndex:10];
    NSString * yesterdayString = [[yesterday description] substringToIndex:10];
    
    if ([strDate isEqualToString:todayString])
    {
        return @"今天";
    } else if ([strDate isEqualToString:yesterdayString])
    {
        return @"昨天";
    }
    else
    {
        return strDate;
    }
}


#pragma mark - 网络请求
-(void)getChargingData{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    [self.dataSource removeAllObjects];
    [self clearViewNoData];
    
    NSString *startTime = @"";
    NSString *endTime = @"";

    NSString *urlString = @"";
    if (_curIndex == 0 ) {
        urlString = LLC_GET_CENTER_CONSUMPTION_ACTION;
    }else if (_curIndex == 1 ) {
        urlString = LLC_GET_CENTER_RECHARGE_ACTION;
    }else if (_curIndex == 2 ) {
        urlString = LLC_GET_400PACKAGE_CONSUMPTION_ACTION;
    }else if (_curIndex == 3 ) {
        urlString = LLC_GET_400PACKAGE_RECHARGE_ACTION;
    }
    
    ///消费
    if (_curIndex == 0 || _curIndex == 2) {
        startTime = [NSString stringWithFormat:@"%@-01",curSelectDateYM];
        endTime = [NSString stringWithFormat:@"%@-%ti",curSelectDateYM,[self getMonthDaysByDate:curSelectDateYM]];
    }else{
        ///充值
        startTime = [NSString stringWithFormat:@"%@-01-01",curSelectDateY];
        endTime = [NSString stringWithFormat:@"%@-12-%ti",curSelectDateY,[self getMonthDaysByDate:[NSString stringWithFormat:@"%@-12",curSelectDateY]]];
        ;
    }
   
    //startTime
    //endTime
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:nil];
    [params setValue:startTime forKey:@"startTime"];
    [params setValue:endTime forKey:@"endTime"];
    
    NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:params]
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString:%@",jsonString);
    
    ///dic转换为json
    NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rParam setObject:jsonString forKey:@"data"];
    NSLog(@"rParam:%@",rParam);
    
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,urlString] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            
            id data = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"data"];
            //            if ([data respondsToSelector:@selector(count)] && [data count] > 0) {
            [self setViewRequestSusscess:jsonResponse];
            //            }
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getChargingData];
            };
            [comRequest loginInBackgroundLLC];
        }
        else {
            //获取失败
            NSString *desc = [jsonResponse safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"加载失败";
            }
        }
        ///刷新UI
        [self notifyViewData];
        [self notifyNoDataView];
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
        NSLog(@"%@",error);
        [self notifyViewData];
        [self notifyNoDataView];
    }];
    
}


///请求成功
-(void)setViewRequestSusscess:(NSDictionary *)jsonResponse{

    if (_curIndex == 0 ||_curIndex == 2) {
//        if (_curIndex == 0) {
//            jsonResponse = [CommonFunc readJsonFile:@"charge-xf"];
//        }else{
//            jsonResponse = [CommonFunc readJsonFile:@"charge-400xf"];
//        }
        [self.dataSource addObjectsFromArray:[[jsonResponse objectForKey:@"resultMap"] objectForKey:@"data"]];
    }else if (_curIndex == 1 || _curIndex == 3 ){
        [self transFromData:[[jsonResponse objectForKey:@"resultMap"] objectForKey:@"data"]];
    }
    
    NSLog(@"self.dataSource:%@",self.dataSource);
}

///刷新UI数据
-(void)notifyViewData{
    ///刷新UI
    if (_curIndex == 0 || _curIndex == 2) {
        
        [self notifyChartViewData];
    }
    else if (_curIndex == 1 || _curIndex == 3 ){
        [self.tableview reloadData];
    }
}

#pragma mark - 没有数据时的view

-(void)notifyNoDataView{
    if (self.dataSource && [self.dataSource count] > 0) {
        [self clearViewNoData];
    }else{
        if (_curIndex == 0 || _curIndex == 2) {
            [self setViewNoData:@"暂无消费记录"];
        }else{
            [self setViewNoData:@"暂无充值记录"];
        }
    }
}


-(void)setViewNoData:(NSString *)title{
    if (self.commonNoDataView == nil) {
        self.commonNoDataView = [CommonFunc commonNoDataViewIcon:@"list_empty.png" Title:title optionBtnTitle:@""];
    }
    if (_curIndex == 0 || _curIndex == 2) {
        [self.view addSubview:self.commonNoDataView];
    }else{
        [self.tableview addSubview:self.commonNoDataView];
    }
}

-(void)clearViewNoData{
    if (self.commonNoDataView) {
        [self.commonNoDataView removeFromSuperview];
        self.commonNoDataView = nil;
    }
}


@end
