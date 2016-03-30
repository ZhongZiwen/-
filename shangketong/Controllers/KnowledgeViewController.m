//
//  KnowledgeViewController.m
//  shangketong
//
//  Created by sungoin-zjp on 27/5/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "KnowledgeViewController.h"
#import "CommonConstant.h"
#import "CommonFuntion.h"
#import "KnowledgeFileViewController.h"

@interface KnowledgeViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchDisplayDelegate,UISearchBarDelegate>{
    UISearchBar *searchBar;
    UISearchDisplayController *searchDisplayController;
    NSArray *filterArray;
    
    ///类型
    NSArray *arrKnowledgeType;
    
#warning 测试数据
    ///搜索历史
    NSMutableArray *arraySearchHistory;
    ///搜索“xxx”
    BOOL isShowSearchServer;
    
    ///显示的array
    NSMutableArray *arrayShow;
}

@end

@implementation KnowledgeViewController

- (void)loadView
{
    [super loadView];
    self.title = @"知识库";
    self.view.backgroundColor = kView_BG_Color;
    
    [self initTableviewAndDate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self readSearchHistory];
}


#pragma mark - 初始化数据
-(void)initData{
    isShowSearchServer = FALSE;
    arrKnowledgeType = [[NSArray alloc] initWithObjects:@"公司知识库",@"我的知识库", nil];
    arraySearchHistory = [[NSMutableArray alloc] init];
    arrayShow = [[NSMutableArray alloc] init];
}

#pragma mark - 搜索历史  测试数据
-(void)readSearchHistory{
    NSArray *arrayS = [[NSArray alloc] init];
    [arraySearchHistory addObjectsFromArray:arrayS];
    [arrayShow  addObjectsFromArray:arraySearchHistory];
}

#pragma mark - 初始化tablview
-(void)initTableviewAndDate{
    self.tableviewKnowledge = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableviewKnowledge.delegate = self;
    self.tableviewKnowledge.dataSource = self;
    self.tableviewKnowledge.sectionFooterHeight = 0;
    
    [self.view addSubview:self.tableviewKnowledge];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableviewKnowledge setTableFooterView:v];
    
    
    
    
    /*
    UIView *searView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 44)];
    searView.backgroundColor = [UIColor whiteColor];
    
    UIButton *btnSearch = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSearch.frame = CGRectMake(5, 5, kScreen_Width-10, 30);
    [btnSearch setBackgroundImage:[UIImage imageNamed:@"img_searchbar_view_bg.png"] forState:UIControlStateNormal];
    [btnSearch addTarget:self action:@selector(gotoSearchView) forControlEvents:UIControlEventTouchUpInside];
    
    
    NSInteger vX = kScreen_Width/2-30;
    UIImageView *imgIcon = [[UIImageView alloc] initWithFrame:CGRectMake(vX, 13, 22, 22)];
    imgIcon.image = [UIImage imageNamed:@"img_search_icon.png"];
    
    
    UILabel *labelTag = [[UILabel alloc] initWithFrame:CGRectMake(vX+22, 5, 120, 36)];
    labelTag.font = [UIFont systemFontOfSize:14.0];
    labelTag.textColor = [UIColor grayColor];
    labelTag.text = @"搜索";
    
    
    
    [searView addSubview:btnSearch];
    [searView addSubview:imgIcon];
    [searView addSubview:labelTag];
    
    self.tableviewKnowledge.tableHeaderView = searView;
    */
    
    
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width,44)];
    searchBar.placeholder = @"搜索";
    searchBar.translucent = YES;
    searchBar.delegate = self;
    [searchBar sizeToFit];
    
    
//    for (UIView *view in searchBar.subviews) {
//        // for later iOS7.0(include)
//        if ([view isKindOfClass:NSClassFromString(@"UIView")] && view.subviews.count > 0) {
//            [[view.subviews objectAtIndex:0] removeFromSuperview];
//            break;
//        }
//    }
    

    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    searchBar.contentMode = UIViewContentModeLeft;
//    [searchBar setBarTintColor:[UIColor clearColor]];
//    searchBar.searchBarStyle = UISearchBarStyleMinimal;
//    [searchBar setBackgroundColor:[UIColor blueColor]];
    searchBar.backgroundImage = [CommonFuntion createImageWithColor:COLOR_SEARCHBAR_BG];
    self.tableviewKnowledge.tableHeaderView = searchBar;
    
    // 用 searchbar 初始化 SearchDisplayController
    // 并把 searchDisplayController 和当前 controller 关联起来
    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;
    
    ///去除多余得分割线
    UIView *vs = [[UIView alloc] initWithFrame:CGRectZero];
    [searchDisplayController.searchResultsTableView setTableFooterView:vs];
    
    [searchDisplayController.searchResultsTableView reloadData];
    searchDisplayController.searchBar.tintColor = LIGHT_BLUE_COLOR;
}


-(void)gotoSearchView{

}


#pragma mark - Table view data source
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (isShowSearchServer) {
        return 60.0;
    }
    return 0.5;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (isShowSearchServer) {
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 60)];
        headView.backgroundColor = [UIColor grayColor];
        
        UIImageView *imgIcon = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 40, 40)];
        imgIcon.image = [UIImage imageNamed:@"searchSever.png"];
        [headView addSubview:imgIcon];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(70, 20, kScreen_Width-80, 20)];
        label.text = [NSString stringWithFormat:@"搜索“%@”",searchBar.text];
        label.font = [UIFont systemFontOfSize:14.0];
        [headView addSubview:label];
        
        
        return headView;
    }else{
        return nil;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == self.tableviewKnowledge) {
        if (arrKnowledgeType) {
            return [arrKnowledgeType count];
        }
    }else if (tableView == searchDisplayController.searchResultsTableView){
        if (arrayShow) {
//            NSLog(@"searchResultsTableView:%@",arrayShow);
            return [arrayShow count];
        }
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableviewKnowledge) {
        return 45.0;
    }else if (tableView == searchDisplayController.searchResultsTableView){
        return 40.0;
    }
    return 45.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableviewKnowledge) {
        static NSString *cellIdentifier = @"KnowledgeviewCellIdentifier";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell==nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.accessoryType  = UITableViewCellAccessoryNone;
        }
        
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
        cell.textLabel.text = [arrKnowledgeType objectAtIndex:indexPath.row];
        cell.imageView.image = [UIImage imageNamed:@"file_floder.png"];
        
        return cell;

    }else if (tableView == searchDisplayController.searchResultsTableView){
        static NSString *cellIdentifier = @"KnowledgeviewSearchCellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell==nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.accessoryType  = UITableViewCellAccessoryNone;
        }
        
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];

        NSLog(@"search history:%@",[arrayShow objectAtIndex:indexPath.row]);
        cell.textLabel.text = [arrayShow objectAtIndex:indexPath.row];
        NSLog(@"");
        return cell;
    }
    return nil;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == self.tableviewKnowledge) {
        KnowledgeFileViewController *controller = [[KnowledgeFileViewController alloc] init];
        if (indexPath.row == 0) {
            controller.typeKnowledgeRequest = 0;
        }else{
            controller.typeKnowledgeRequest = 1;
        }
        controller.typeKnowledge = indexPath.row;
        controller.strTitle = [arrKnowledgeType objectAtIndex:indexPath.row];
        controller.dirId = -1;
        controller.departmengOrGroupId = -1;
        [self.navigationController pushViewController:controller animated:YES];
    }else if (tableView == searchDisplayController.searchResultsTableView){
        
    }
}


#pragma mark - searchbar delegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar1
{
     NSLog(@"searchBarTextDidBeginEditing---->");
    
    searchBar.showsCancelButton = YES;
    //    NSLog(@"subview count:%li",(unsigned long)[self.searchBar.subviews count]);
    for(id cc in [searchBar.subviews[0] subviews])
        //    for(id cc in [self.searchBar subviews])
    {
        //        NSLog(@"subview:%@",cc);
        if([cc isKindOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton *)cc;
            [btn setTitle:@"取消"  forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        }
        
        if([cc isKindOfClass:[UITextField class]])
        {
            UITextField *txt = (UITextField *)cc;
            txt.placeholder = @"搜索";
        }
    }
}


#pragma mark - 搜索相关

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    isShowSearchServer = FALSE;
    [arrayShow removeAllObjects];
    [self.tableviewKnowledge reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar2 textDidChange:(NSString *)searchText;
{
    NSLog(@"textDidChange---->");
    if (searchText == nil || [searchText isEqualToString:@""]) {
        searchBar2.text = @" ";
    }
    if (searchText != nil && ![searchText isEqualToString:@" "] && searchText.length > 0) {
        isShowSearchServer = TRUE;
        [arrayShow  removeAllObjects];
    }
    else
    {
        ///
        isShowSearchServer = FALSE;
        [arrayShow removeAllObjects];
        [arrayShow  addObjectsFromArray:arraySearchHistory];
    }
    
    [searchDisplayController.searchResultsTableView reloadData];
    [self.tableviewKnowledge reloadData];
    ///滑动到最顶部
    [self.tableviewKnowledge setContentOffset:CGPointZero animated:NO];
}

///重置搜索结果
-(void)resetSearchResult{
    ///search result list
    NSInteger count = 0;
    for (NSString *name in arraySearchHistory) {
        ///loop array
        
    }
}



//-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar2{
//    searchBar.text = @" ";
//    [searchDisplayController.searchResultsTableView reloadData];
//    return YES;
//}

//
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    NSLog(@"shouldReloadTableForSearchString---->");
    
    
//    if (![searchString isEqualToString:@" "]) {
//        UITableView *tableView1 = self.searchDisplayController.searchResultsTableView;
//        for( UIView *subview in tableView1.subviews ) {
//            if( [subview class] == [UILabel class] ) {
//                UILabel *lbl = (UILabel*)subview; // sv changed to subview.
//                lbl.text = @"没有结果";
//            }
//        }
//    }
    
    return YES;
}






@end
