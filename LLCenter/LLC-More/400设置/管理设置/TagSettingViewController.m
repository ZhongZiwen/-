//
//  TagSettingViewController.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-13.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "TagSettingViewController.h"
#import "LLCenterUtility.h"
#import "CommonFunc.h"
#import "TagSeetingCollectionViewCell.h"
#import "TagSettingHeadCollectionReusableView.h"
#import "CustomPopView.h"
#import "AddTagsViewController.h"
#import "CommonNoDataView.h"

@interface TagSettingViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate>{
    
    ///normal delete
    NSString *actionType;
}

@property (nonatomic, strong) CommonNoDataView *commonNoDataView;
@property(strong,nonatomic) UICollectionView *collectionView;
@property(strong,nonatomic) NSMutableArray *dataSource;

@end

@implementation TagSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"标签设置";
    [super customBackButton];
    self.view.backgroundColor = COLOR_BG;
    
    [self initData];
    [self initCollectionView];
    [self.collectionView reloadData];
    [self getCustomerTags];
}


#pragma mark - 初始化数据
-(void)initData{
    actionType = @"normal";
    self.dataSource = [[NSMutableArray alloc] init];
}

#pragma mark - Nav Bar
-(void)addNavBar{
    
    UIButton *rightButton=[UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame=CGRectMake(0, 0, 25, 16);
    [rightButton setBackgroundImage:[UIImage imageNamed:@"icon_more_function.png"] forState:UIControlStateNormal];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"icon_more_function.png"] forState:UIControlStateHighlighted];
    [rightButton addTarget:self action:@selector(rightBarButtonAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    [self.navigationItem setRightBarButtonItem:rightBarButton];
    
}

///
-(void)rightBarButtonAction{
    [self showPopView];
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
    [self.collectionView reloadData];
}


-(void)showPopView{
    CustomPopView *popView = [[CustomPopView alloc] initWithPoint:CGPointMake(0, 64+64) titles:@[@"新增标签", @"删除标签"] imageNames:@[@"icon_add_dictionary.png", @"icon_delete_img.png"]];
    __weak typeof(self) weak_self = self;
    popView.selectBlock = ^(NSInteger index) {
        if (index == 0) {
            [weak_self addNewTags];
        }else if (index == 1){
            [self deleteTags];
        }
    };
    [popView show];
}

///新增标签
-(void)addNewTags{
    AddTagsViewController *controller = [[AddTagsViewController alloc] init];
    __weak typeof(self) weak_self = self;
    controller.NotifyTagsList = ^(){
        
        [weak_self getCustomerTags];
    };
    controller.title = @"新增标签";
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)deleteTags{
    [self addRightOkBarBtn];
    actionType = @"delete";
    [self.collectionView reloadData];
}


///初始化collectionview
-(void)initCollectionView{
    UICollectionViewFlowLayout *layout= [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize=CGSizeMake(DEVICE_BOUNDS_WIDTH/3-10,60);
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, DEVICE_BOUNDS_HEIGHT-64) collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"TagSeetingCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"TagSeetingCollectionViewCell"];
    self.collectionView.delegate=self;
    self.collectionView.dataSource=self;
    self.collectionView.allowsMultipleSelection = YES;//默认为NO,是否可以多选
    self.collectionView.alwaysBounceVertical = YES;
    
    
    //注册headerView Nib的view需要继承UICollectionReusableView
    [self.collectionView registerNib:[UINib nibWithNibName:@"TagSettingHeadCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"TagSettingHeadCollectionReusableView"];
    
    [self.view addSubview:self.collectionView];

}

#pragma mark -CollectionView datasource
//section
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.dataSource) {
        return [self.dataSource count];
    }
    return 0;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //重用cell
    TagSeetingCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TagSeetingCollectionViewCell" forIndexPath:indexPath];
    
    [cell setCellFrame:indexPath];
    [cell.btnTag setTitle:[[self.dataSource objectAtIndex:indexPath.row] safeObjectForKey:@"FLAGVALUE"] forState:UIControlStateNormal];
//    cell.backgroundColor = [UIColor grayColor];
    
    if ([actionType isEqualToString:@"delete"]) {
        cell.imgDeleteIcon.hidden = NO;
        __weak typeof(self) weak_self = self;
        cell.DeleteTagBlock = ^(NSInteger index){
            [weak_self showDeleteAlert:index];
        };
    }else{
        cell.imgDeleteIcon.hidden = YES;
    }
    
    
    
    return cell;
    
}
// The view that is returned must be retrieved from a call to -dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    NSString *reuseIdentifier;
    if ([kind isEqualToString: UICollectionElementKindSectionHeader]){
        reuseIdentifier = @"TagSettingHeadCollectionReusableView";
    }
    
    UICollectionReusableView *view =  [collectionView dequeueReusableSupplementaryViewOfKind :kind   withReuseIdentifier:reuseIdentifier   forIndexPath:indexPath];
    
    return view;
}

//定义每个UICollectionViewCell 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(DEVICE_BOUNDS_WIDTH/3-10, 40);
}
//定义每个Section 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 5, 0, 5);//分别为上、左、下、右
}


//每个section中不同的行之间的行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}

//返回头headerView的大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{

    if (self.dataSource && [self.dataSource count] > 0) {
        CGSize size = {DEVICE_BOUNDS_WIDTH,50};
        return size;
    }
    CGSize  sizeNil = {0,0};
    return sizeNil;
}

//每个item之间的间距
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
//{
//    return 100;
//}
//选择了某个cell
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectItemAtIndexPath----->");
}
//取消选择了某个cell
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}


#pragma mark - UIAlertView

///删除提示框
-(void)showDeleteAlert:(NSInteger)index{
    NSString *tag = [[self.dataSource objectAtIndex:index] safeObjectForKey:@"FLAGVALUE"];
    NSString *messge = [NSString stringWithFormat:@"是否删除当前标签?\n%@",tag];
    UIAlertView *alertCall = [[UIAlertView alloc] initWithTitle:nil message: messge delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    alertCall.tag = index;
    [alertCall show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //删除
    if (buttonIndex == 1) {
        NSLog(@"delete index:%ti",alertView.tag);
        [self deleteTag:[[self.dataSource objectAtIndex:alertView.tag] safeObjectForKey:@"ID"] index:alertView.tag];
    }
}

#pragma mark - 网络请求

#pragma mark - 客户标签
-(void)getCustomerTags{
    [self clearViewNoData];
    NSString *requestAction = LLC_GET_CUSTOMER_STATE_FLAG_ACTION;
    
    NSMutableDictionary *rDict = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:nil];
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_GET_CUSTOMER_STATE_FLAG_ACTION] params:params success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"客户标签jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            id data = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"data"];
            if ([data respondsToSelector:@selector(count)] && [data count] > 0) {
                [self addNavBar];
                [self.dataSource removeAllObjects];
                [self.dataSource addObjectsFromArray:[[jsonResponse objectForKey:@"resultMap"] objectForKey:@"data"]];
            }
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getCustomerTags];
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
        [self notifyNoDataView];
        [self.collectionView reloadData];
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
        [self notifyNoDataView];
        [self.collectionView reloadData];
    }];
}


#pragma mark - 删除标签

-(void)deleteTag:(NSString *)flagId index:(NSInteger)index{
    
    ///传入：flagName
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *rDict = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rDict setValue:flagId forKey:@"flagId"];
    [rDict setValue:[[self.dataSource objectAtIndex:index] safeObjectForKey:@"FLAGVALUE"] forKey:@"flagName"];
    
    NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:rDict]
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString:%@",jsonString);
    
    ///dic转换为json
    NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rParam setObject:jsonString forKey:@"data"];
    NSLog(@"rParam:%@",rParam);
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_DELETE_CUSTOMER_STATEFLAG_ACTION] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"删除标签jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            
            [CommonFuntion showToast:@"删除成功" inView:self.view];
            [self.dataSource removeObjectAtIndex:index];
            [self.collectionView reloadData];
            
            ///刷出数据
            if ([self.dataSource count] == 0) {
                actionType = @"normal";
                [self rightOkBarButtonAction];
                [self getCustomerTags];
            }
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self deleteTag:flagId index:index];
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
        [self setViewNoData:@"加载失败"];
    }
}

-(void)setViewNoData:(NSString *)title{
    if (self.commonNoDataView == nil) {
        self.commonNoDataView = [CommonFunc commonNoDataViewIcon:@"list_empty.png" Title:title optionBtnTitle:@""];
    }
    
    [self.collectionView addSubview:self.commonNoDataView];
}

-(void)clearViewNoData{
    if (self.commonNoDataView) {
        [self.commonNoDataView removeFromSuperview];
    }
}


@end
