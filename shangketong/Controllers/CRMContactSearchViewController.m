//
//  ContactSearchViewController.m
//  shangketong
//
//  Created by sungoin-zjp on 15-6-15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "CRMContactSearchViewController.h"
#import "CommonFuntion.h"
#import "CommonConstant.h"
#import "ContactCell.h"
#import "ContactSearchResultViewController.h"

@interface CRMContactSearchViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,ContactCellDelegate,UISearchBarDelegate>{
    UITextField *searchTextField;
    UISearchBar *searchBar;
//    UISearchDisplayController *searchDisplayController;
    
    ///搜索结果
    NSMutableArray *arraySearchResults;
    NSArray *arrayShow;
    
    ///是否显示headview
    BOOL isShowHeadView;
    
    ///搜索网络数据
    UIButton *btnSearchServiceData;
}

@end

@implementation CRMContactSearchViewController

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = VIEW_BG_COLOR;
    
    [self initSearchBarView];
    [self initTableview];
    [self addTouchesEvent];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    [self readTestData];
    
    [self.tableviewContact reloadData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


#pragma mark - 初始化数据
-(void)initData{
    if ([self.typeContact isEqualToString:@"lately-contact"]) {
        isShowHeadView = YES;
    }else if ([self.typeContact isEqualToString:@"contact"]) {
        isShowHeadView = YES;
    }
    self.arrayContact = [[NSMutableArray alloc] init];
    arraySearchResults = [[NSMutableArray alloc] init];
}

#pragma mark - 读取测试数据
-(void)readTestData{
    id jsondata = [CommonFuntion readJsonFile:@"contact-list-data"];
    NSLog(@"jsondata:%@",jsondata);
    
    NSArray *array = [[jsondata objectForKey:@"body"] objectForKey:@"contacts"];
    [self.arrayContact addObjectsFromArray:array];
    
    arrayShow = self.arrayContact;
}


#pragma mark - 初始化tablview
-(void)initTableview{
    self.tableviewContact = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64) style:UITableViewStylePlain];
    [self.tableviewContact registerNib:[UINib nibWithNibName:@"ContactCell" bundle:nil] forCellReuseIdentifier:@"ContactCellIdentify"];
    self.tableviewContact.delegate = self;
    self.tableviewContact.dataSource = self;
    self.tableviewContact.sectionFooterHeight = 0;
    [self.view addSubview:self.tableviewContact];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableviewContact setTableFooterView:v];
}


#pragma mark - 初始化searchbar
-(void)initSearchBarView{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 64)];
    headView.backgroundColor = [UIColor clearColor];
    
    /*
    searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 25, self.view.bounds.size.width-60, 30)];
    searchTextField.borderStyle = UITextBorderStyleRoundedRect;
    searchTextField.font = [UIFont systemFontOfSize:14.0];
    searchTextField.placeholder = @"搜索";
    searchTextField.returnKeyType = UIReturnKeySearch;
    //设置为无文字就灰色不可点
    //    searchTextField.enablesReturnKeyAutomatically = YES;
    searchTextField.delegate = self;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    searchTextField.leftView = view;
    searchTextField.leftViewMode = UITextFieldViewModeAlways;
    [headView addSubview:searchTextField];
    [searchTextField becomeFirstResponder];
    
    UIImageView *iconSearch = [[UIImageView alloc] initWithFrame:CGRectMake(15, 30, 20, 20)];
    iconSearch.image = [UIImage imageNamed:@"img_search_icon.png"];
    [headView addSubview:iconSearch];
    
    */
    

    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(5, 25, self.view.bounds.size.width-50, 30)];
    searchBar.delegate = self;
    searchBar.placeholder = @"搜索";
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    searchBar.keyboardType = UIKeyboardTypeNamePhonePad;
    searchBar.contentMode = UIViewContentModeLeft;
    //    [self.searchbar setBarTintColor:[UIColor clearColor]];
    //    self.searchbar.searchBarStyle = UISearchBarStyleMinimal;
    [headView addSubview:searchBar];
    

//    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
//    
//    searchDisplayController.searchResultsDataSource = self;
//    searchDisplayController.searchResultsDelegate = self;
//    
//    ///去除多余得分割线
//    UIView *vs = [[UIView alloc] initWithFrame:CGRectZero];
//    [searchDisplayController.searchResultsTableView setTableFooterView:vs];
    
    
    for (UIView *view in searchBar.subviews) {
        // for later iOS7.0(include)
        if ([view isKindOfClass:NSClassFromString(@"UIView")] && view.subviews.count > 0) {
            [[view.subviews objectAtIndex:0] removeFromSuperview];
            break;
        }
    }
    
    [searchBar becomeFirstResponder];
    
    
    btnSearchServiceData = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSearchServiceData.frame = CGRectMake(0,0 , kScreen_Width, 40);
    btnSearchServiceData.backgroundColor = [UIColor grayColor];
    [btnSearchServiceData setTitle:@"点击搜索网络数据" forState:UIControlStateNormal];
    [btnSearchServiceData setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btnSearchServiceData addTarget:self action:@selector(searchSeviceData) forControlEvents:UIControlEventTouchUpInside];
    
    searchBar.inputAccessoryView = btnSearchServiceData;
    
    
    UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCancel.frame = CGRectMake(self.view.bounds.size.width-50, 20, 50, 40);
    [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
    btnCancel.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnCancel addTarget:self action:@selector(cancelEvent) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:btnCancel];
    
    [self.view addSubview:headView];
}

/*
-(void)initSearchBarView2{
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width-50, 40)];
    searchBar.delegate = self;
    searchBar.placeholder = @"搜索";
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    searchBar.keyboardType = UIKeyboardTypeNamePhonePad;
    searchBar.contentMode = UIViewContentModeLeft;
    //    [self.searchbar setBarTintColor:[UIColor clearColor]];
    //    self.searchbar.searchBarStyle = UISearchBarStyleMinimal;
    [headView addSubview:self.searchbar];
    
    
    for (UIView *view in searchBar.subviews) {
        // for later iOS7.0(include)
        if ([view isKindOfClass:NSClassFromString(@"UIView")] && view.subviews.count > 0) {
            [[view.subviews objectAtIndex:0] removeFromSuperview];
            break;
        }
    }
    
    [searchBar becomeFirstResponder];
}
*/


///取消事件
///
-(void)cancelEvent{
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == self.tableviewContact)
    {
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    ///编辑状态时 不显示headview
    if (isShowHeadView) {
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 25)];
        headView.backgroundColor = [UIColor grayColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 150, 25)];
        label.text = @"";
        label.font = [UIFont systemFontOfSize:16.0];
        [headView addSubview:label];
        
        if ([self.typeContact isEqualToString:@"lately-contact"]) {
            label.text = @"最近浏览";
        }else if ([self.typeContact isEqualToString:@"contact"]){
            label.text = @"搜索历史";
        }
        return headView;
    }
    
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if ( isShowHeadView) {
        return 25.0;
    }
    return 1.;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if ([self.typeContact isEqualToString:@"lately-contact"]) {
        return 1;
    }else if ([self.typeContact isEqualToString:@"contact"]){
        return 1;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (arrayShow) {
        return [arrayShow count];
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ContactCellIdentify";
    ContactCell *cell = (ContactCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"ContactCell" owner:self options:nil];
        cell = (ContactCell*)[array objectAtIndex:0];
        [cell awakeFromNib];
    }
    
    cell.ccdelegate = self;
    [cell setCellFrame];
    [cell setCellDetails:[arrayShow objectAtIndex:indexPath.row]];
    [cell setCallBtnShow:[arrayShow objectAtIndex:indexPath.row] index:indexPath];
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ///判断是否可选择
    if (indexPath.row/2 == 0) {
        [searchTextField resignFirstResponder];
//        [self dismissViewControllerAnimated:YES completion:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    ///判断是最近联系人还是联系人
    if ([self.typeContact isEqualToString:@"contact"]) {
        
    }else if ([self.typeContact isEqualToString:@"lately-contact"]){
        ///
    }
}


/*
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    NSString *strSearch = textField.text;
    NSLog(@"strSearch:%@",strSearch);
    return YES;
}
 */

#pragma mark - 拨打联系人事件回调
-(void)callCantact:(NSInteger)index{
    NSLog(@"callCantact:%li",index);
}

#pragma mark - 键盘事件
-(void)addTouchesEvent{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}


-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    [searchTextField resignFirstResponder];
}


#pragma mark - 搜索相关
- (void)searchBar:(UISearchBar *)searchBar2 textDidChange:(NSString *)searchText;
{
    if (searchText!=nil && searchText.length>0) {
        isShowHeadView = NO;
        [self searchResult:searchText];
        if (arraySearchResults && [arraySearchResults count]>0) {
            arrayShow = arraySearchResults;
        }else{
            arrayShow = self.arrayContact;
        }
    }
    else
    {
        isShowHeadView = YES;
        ///若输入为空 则显示所有数据
        arrayShow = self.arrayContact;
    }
    [self.tableviewContact reloadData];
}

/*
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchbar
{
    [self searchBar:searchBar textDidChange:nil];
    [searchBar resignFirstResponder];
    NSLog(@"searchBarCancelButtonClicked-->");
}
 */

///搜索事件
-(void) searchBarSearchButtonClicked:(UISearchBar *)searchbar {
//    [self searchBar:searchBar textDidChange:nil];
    [searchBar resignFirstResponder];
    NSLog(@"searchBarSearchButtonClicked-->");
    
    ///搜索事件
    [self searchSeviceDataByKeyWord:searchbar.text];
}

///根据输入的关键词做匹配
-(void)searchResult:(NSString *)searchStr{
    [arraySearchResults removeAllObjects];
    
    NSInteger countAll = 0;
    if (self.arrayContact) {
        countAll = [self.arrayContact count];
    }
    
    //所有数据
    for(int i=0; i < countAll; i++)
    {
        NSString *name = [[NSString alloc]init];
        name = [[self.arrayContact objectAtIndex:i]objectForKey:@"name"];
        if ([self searchResult:name searchText:searchStr]){
            [arraySearchResults addObject:[self.arrayContact objectAtIndex:i]];
        }
    }
}

///匹配
-(BOOL)searchResult:(NSString *)contactName searchText:(NSString *)searchT{
    if (contactName==nil || searchT == nil || (id)contactName == [NSNull null] || [contactName isEqualToString:@"(null)"] || [contactName isEqualToString:@"<null>"]) {
        return NO;
    }
    NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
    NSRange productNameRange = NSMakeRange(0, contactName.length);
    NSRange foundRange = [contactName rangeOfString:searchT options:searchOptions range:productNameRange];
    if (foundRange.length > 0)
        return YES;
    else
        return NO;
}


#pragma mark -   搜索网络数据
///keyboardview event
-(void)searchSeviceData{
    NSString *searchStr = searchBar.text;
    [self searchSeviceDataByKeyWord:searchStr];
}

///搜索事件
-(void)searchSeviceDataByKeyWord:(NSString *)keyWord{
    ContactSearchResultViewController *controller = [[ContactSearchResultViewController alloc] init];
    controller.typeContact = self.typeContact;
    [self.navigationController pushViewController:controller animated:YES];
}


@end
