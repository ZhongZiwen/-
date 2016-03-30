//
//  ExportAddressViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/5/6.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ExportAddressViewController.h"
#import "ExportAddressTableViewCell.h"
#import "ExportBottomTableViewCell.h"
#import "ExportAddress.h"
#import <AddressBook/AddressBook.h>

#define kCellIdentifier @"ExportAddressTableViewCell"
#define kBottomCellIdentifier @"ExportBottomTableViewCell"

@interface ExportAddressViewController ()

@property (strong, nonatomic) ExportAddress *bottomExport;

@property (strong, nonatomic) UIView *bottomView;
@property (strong, nonatomic) UITableView *bottomTableView;
@property (strong, nonatomic) UILabel *bottomSelectedLabel;
@property (strong, nonatomic) UIButton *bottomConfirmBtn;       // 确认按钮
@property (strong, nonatomic) NSMutableArray *phoneAddressBook; // 本机通讯录数据

@property (assign, nonatomic) BOOL isAllSeledted;

@property (assign, nonatomic) NSInteger countSuccess;   // 成功导出数

- (void)updateBottomView;   // 更新bottomSelectedLabel和bottomConfirmBtn的属性值
@end

@implementation ExportAddressViewController
@synthesize rowDescriptor = _rowDescriptor;
@synthesize popoverController = __popoverController;

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    
    // 自定义返回按钮 开启手势返回
    self.navigationController.interactivePopGestureRecognizer.delegate=(id)self;
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"取消" target:self action:@selector(leftButtonItemPress)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"全选" target:self action:@selector(rightButtonItemPress)];
    
    [self.tableView registerClass:[ExportAddressTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
    [self.tableView setHeight:CGRectGetHeight(self.tableView.bounds) - 54];
    [self.mSearchDisplayController.searchResultsTableView registerClass:[ExportAddressTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
    
    [self.view addSubview:self.bottomView];
    [_bottomView addSubview:self.bottomTableView];
    [_bottomView addSubview:self.bottomSelectedLabel];
    [_bottomView addSubview:self.bottomConfirmBtn];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 导出通讯录
    if ([self.title isEqualToString:@"导出到手机"]) {
        // 实例化通讯录对象
        ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
            ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
                [self copyAddressBook:addressBookRef];
                
                if (addressBookRef) {
                    CFRelease(addressBookRef);
                }
            });
        }
        else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
            [self copyAddressBook:addressBookRef];
            
            if (addressBookRef) {
                CFRelease(addressBookRef);
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                // 更新界面
                [NSObject showHudTipStr:@"没有获取通讯录权限"];
            });
        }
    }
    
    if (!self.sourceArray.count) {
        [self.view beginLoading];
        [self sendRequest];
        return;
    }
    
    for (AddressBook *selectedItem in _selectedArray) {
        for (AddressBook *tempItem in self.sourceArray) {
            if ([selectedItem.id isEqualToNumber:tempItem.id]) {
                [self.sourceArray removeObject:tempItem];
                break;
            }
        }
    }
    
    [self groupingDataSourceFrom:self.sourceArray to:self.groupsArray];
    [self sortForArray:self.groupsArray];
    [self.tableView configBlankPageWithTitle:@"暂无可选成员" hasData:self.groupsArray.count hasError:NO reloadButtonBlock:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - event response
- (void)leftButtonItemPress {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightButtonItemPress {
    
    if (!_isAllSeledted) {
        _isAllSeledted = YES;
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"取消全选" target:self action:@selector(rightButtonItemPress)];
    }else {
        _isAllSeledted = NO;
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"全选" target:self action:@selector(rightButtonItemPress)];
    }
    
    // section
    for (int i = 0; i < self.groupsArray.count; i ++) {
        AddressBookGroup *tempGroup = self.groupsArray[i];
        // row
        for (int j = 0; j < tempGroup.groupItems.count; j ++) {
            AddressBook *tempItem = tempGroup.groupItems[j];
            
            if ([self.title isEqualToString:@"导出到手机"] && !tempItem.mobile && !tempItem.phone) {
                continue;
            }
            
            if (_isAllSeledted) {
                if (tempItem.isSelected) {
                    continue;
                }
                tempItem.isSelected = YES;
                [self.bottomExport.selectedArray insertObject:tempItem atIndex:self.bottomExport.selectedArray.count - 1];
            }
            else {
                [self.bottomExport.selectedArray removeObject:tempItem];
                tempItem.isSelected = NO;
            }

        }
    }
    
    [self.tableView reloadData];
    [_bottomTableView reloadData];
    
    // 让_bottomTableView显示最后一行
    NSIndexPath *lastPath = [NSIndexPath indexPathForRow:[_bottomTableView numberOfRowsInSection:0] - 1 inSection:0];
    [_bottomTableView scrollToRowAtIndexPath:lastPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    [self updateBottomView];
}

- (void)confirmButtonPress {
    
    // 导出通讯录
    if ([self.title isEqualToString:@"导出到手机"]) {
        ///导出通讯录
        if (ABAddressBookGetAuthorizationStatus() != kABAuthorizationStatusAuthorized) {
            [CommonFuntion showToast:@"未获取到通讯录权限" inView:self.view];
        }else{
            [self exportContact];
        }
        return;
    }
    
    if (_isActivityRecExport && self.bottomExport.selectedArray.count > 5) {
        kShowHUD(@"最多只能选择4个下属");
        return;
    }
    
    if (self.valueBlock) {
        [self.bottomExport.selectedArray removeLastObject];
        
        self.valueBlock(self.bottomExport.selectedArray);
        if (_isActivityRecExport) {
            [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
        }
        else {
            [self.navigationController popViewControllerAnimated:YES];
        }
        return;
    }
    
    [self.bottomExport.selectedArray removeLastObject];
    self.rowDescriptor.value = self.bottomExport;
    
    if (self.popoverController){
        [self.popoverController dismissPopoverAnimated:YES];
        [self.popoverController.delegate popoverControllerDidDismissPopover:self.popoverController];
    }else if ([self.parentViewController isKindOfClass:[UINavigationController class]]){
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - private method
- (void)copyAddressBook:(ABAddressBookRef)addressBookRef {
    CFIndex numberPeople = ABAddressBookGetPersonCount(addressBookRef);
    CFArrayRef arrayPeople = ABAddressBookCopyArrayOfAllPeople(addressBookRef);
    
    for (int i = 0; i < numberPeople; i ++) {
        ABRecordRef person = CFArrayGetValueAtIndex(arrayPeople, i);
        AddressBook *tempItem = [[AddressBook alloc] init];
        
        NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
        tempItem.name = [NSString stringWithFormat:@"%@%@", firstName, lastName];
        
        // 读取电话多值
        ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
        for (int j = 0; j < ABMultiValueGetCount(phone); j ++) {
            // 获取电话Label
//            NSString *personPhoneLabel = (__bridge NSString *)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(phone, j));
            // 获取该Label下的电话
            NSString *personPhone = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phone, j);
            
            if ([NSString isMobileNumber:personPhone]) {
                tempItem.mobile = personPhone;
                break;
            }
        }
        
        [self.phoneAddressBook addObject:tempItem];
    }
}

- (void)updateBottomView {
    if (self.bottomExport.selectedArray.count - 1) {
        _bottomConfirmBtn.enabled = YES;
        
        _bottomSelectedLabel.hidden = NO;
        _bottomSelectedLabel.transform = CGAffineTransformMakeScale(0.8, 0.8);
        _bottomSelectedLabel.text = [NSString stringWithFormat:@"%d", self.bottomExport.selectedArray.count - 1];
        
        [UIView animateWithDuration:0.3 animations:^{
            _bottomSelectedLabel.transform = CGAffineTransformMakeScale(1.125, 1.125);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 animations:^{
                _bottomSelectedLabel.transform = CGAffineTransformMakeScale(0.8, 0.8);
            } completion:nil];
        }];
        
        return;
    }
    
    _bottomConfirmBtn.enabled = NO;
    _bottomSelectedLabel.hidden = YES;
    _bottomSelectedLabel.text = @"0";
}

#pragma mark - UITableView_M
- (NSArray*)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView == self.mSearchDisplayController.searchResultsTableView) {
        return nil;
    }
    if (tableView == _bottomTableView) {
        return nil;
    }
    
    NSMutableArray *indexs = [NSMutableArray array];
    for (AddressBookGroup *group in self.groupsArray) {
        [indexs addObject:group.groupName];
    }
    return indexs;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // 搜索列表
    if (tableView == self.mSearchDisplayController.searchResultsTableView) {
        if (self.searchResults.count) {
            AddressBookGroup *group = self.searchResults[section];
            return group.groupName;
        }
        return @"";
    }
    
    // 主列表
    if (tableView == self.tableView) {
        AddressBookGroup *group = self.groupsArray[section];
        return group.groupName;
    }
    
    // 底部选择表格
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.mSearchDisplayController.searchResultsTableView) {
        if (self.searchResults.count) {
            return self.searchResults.count;
        }
        return 0;
    }
    
    if (tableView == self.tableView) {
        return self.groupsArray.count;
    }
    
    // bottomTableView默认为一组
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.mSearchDisplayController.searchResultsTableView) {
        if (self.searchResults.count) {
            AddressBookGroup *group = self.searchResults[section];
            return group.groupItems.count;
        }
        return 0;
    }
    
    if (tableView == self.tableView) {
        AddressBookGroup *group = self.groupsArray[section];
        return group.groupItems.count;
    }
    
    return [self.bottomExport.selectedArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _bottomTableView) {
        return [ExportBottomTableViewCell cellHeight];
    }
    
    return [ExportAddressTableViewCell cellHeight];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _bottomTableView) {
        ExportBottomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kBottomCellIdentifier forIndexPath:indexPath];
        AddressBook *item = self.bottomExport.selectedArray[indexPath.row];
        [cell configWithModel:item];
        return cell;
    }
    
    ExportAddressTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    if (tableView == self.mSearchDisplayController.searchResultsTableView) {
        AddressBookGroup *group = self.searchResults[indexPath.section];
        [cell configWithModel:group.groupItems[indexPath.row]];
        cell.accessoryView = nil;
    }else {
        AddressBookGroup *group = self.groupsArray[indexPath.section];
        AddressBook *item = group.groupItems[indexPath.row];
        [cell configWithModel:item];
        
        if (!item.isSelected) {    // 没有选中
            // 导出到通讯录，没有手机号的不显示标识
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory_message_normal"]];
            if ([self.title isEqualToString:@"导出到手机"] && !item.mobile && !item.phone) {
                cell.accessoryView = nil;
            }
        }else{      // 选中
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"multi_graph_select"]];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSIndexPath *path = nil;
    AddressBookGroup *group;
    AddressBook *item;
    
    if (tableView == self.bottomTableView) {
        return;
    }
    
    if (tableView == self.tableView) {
        group = self.groupsArray[indexPath.section];
        item = group.groupItems[indexPath.row];
        
        if ([self.title isEqualToString:@"导出到手机"] && !item.mobile && !item.phone) {
            return;
        }
        
        if (item.isSelected) {
            item.isSelected = NO;
            
            // 在bottomSourceArray数组中找到并取消选中该联系人
            for (int i = 0; i < self.bottomExport.selectedArray.count - 1; i ++) {
                AddressBook *tempItem = self.bottomExport.selectedArray[i];
                if ([tempItem.id integerValue] == [item.id integerValue]) {
                    // 赋值path，用于删除在bottomtableview的数据
                    path = [NSIndexPath indexPathForRow:i inSection:0];
                    // 从bottomSourceArray中删除选中数据
                    [self.bottomExport.selectedArray removeObjectAtIndex:i];
                    
                    [self updateBottomView];
                }
            }
            
            // 动态删除cell
            [_bottomTableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationBottom];
            
        }else {
            item.isSelected = YES;
            
            //申明path，在_bottomTableView倒数第二行位置插入数据
            path = [NSIndexPath indexPathForRow:self.bottomExport.selectedArray.count - 1 inSection:0];
            
            // 选中添加数据
            [self.bottomExport.selectedArray insertObject:item atIndex:self.bottomExport.selectedArray.count - 1];
            
            [self updateBottomView];
            
            // 动态插入cell
            [_bottomTableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationBottom];
        }
        
        // 改变当前cell的选中状态
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        // 让_bottomTableView显示最后一行
        path = [NSIndexPath indexPathForRow:[_bottomTableView numberOfRowsInSection:0] - 1 inSection:0];
        [_bottomTableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        return;
    }
    
    group = self.searchResults[indexPath.section];
    item = group.groupItems[indexPath.row];
    
    if (item.isSelected) {
        [self.mSearchDisplayController setActive:NO animated:YES];
        return;
//        item.isSelected = NO;
//        
//        // 在bottomSourceArray数组中找到并取消选中该联系人
//        for (int i = 0; i < _bottomExport.selectedArray.count - 1; i ++) {
//            AddressBook *tempItem = _bottomExport.selectedArray[i];
//            if ([tempItem.id integerValue] == [item.id integerValue]) {
//                // 赋值path，用于删除在bottomtableview的数据
//                path = [NSIndexPath indexPathForRow:i inSection:0];
//                // 从bottomSourceArray中删除选中数据
//                [_bottomExport.selectedArray removeObjectAtIndex:i];
//                
//                [self updateBottomView];
//            }
//        }
//        
//        // 动态删除cell
//        [_bottomTableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationBottom];
    }
    
    item.isSelected = YES;
    
    //申明path，在_bottomTableView倒数第二行位置插入数据
    path = [NSIndexPath indexPathForRow:self.bottomExport.selectedArray.count - 1 inSection:0];
    
    // 选中添加数据
    [self.bottomExport.selectedArray insertObject:item atIndex:self.bottomExport.selectedArray.count - 1];
    
    [self updateBottomView];
    
    // 动态插入cell
    [_bottomTableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationBottom];
    
    [self.tableView reloadData];
    
    // 让_bottomTableView显示最后一行
    path = [NSIndexPath indexPathForRow:[_bottomTableView numberOfRowsInSection:0] - 1 inSection:0];
    [_bottomTableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    [self.mSearchDisplayController setActive:NO animated:YES];
}

#pragma mark - 导出通讯录
////导出操作
-(void)exportContact{
    __weak typeof(self) weak_self = self;
    _countSuccess = 0;
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [CommonFuntion showHUD:@"导出中" andView:self.view andHUD:hud];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.bottomExport.selectedArray removeLastObject];
        for (int i = 0; i < self.bottomExport.selectedArray.count; i++) {
            AddressBook *model = self.bottomExport.selectedArray[i];
            
            BOOL isExist = NO;
            for (AddressBook *tempItem in self.phoneAddressBook) {
                if ([tempItem.mobile isEqualToString:model.mobile]) {
                    isExist = YES;
                    break;
                }
            }
            
            if (isExist) {
                continue;
            }
            
            BOOL isSuccess = [weak_self addContactToPhoneWithname:model];
            if (isSuccess) {
                _countSuccess++;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hide:YES];
            [weak_self resultOfExport];
        });
    });
    
}

-(void)resultOfExport{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"成功导出%ti个联系人", _countSuccess] message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    alert.tag = 101;
    [alert show];
}


#pragma mark - UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //导出完成后确定操作
    if (alertView.tag == 101) {
        if (buttonIndex == 0) {
            NSLog(@"返回------>");
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma  mark 添加联系人到本地通讯录中
- (BOOL)addContactToPhoneWithname:(AddressBook *)model {
    NSString *mobileLabel = @"手机";
    NSString *telLabel = @"电话";
    // 创建一条空的联系人
    ABRecordRef record = ABPersonCreate();
    CFErrorRef error;
    // 设置联系人的名字
    ABRecordSetValue(record, kABPersonFirstNameProperty, (__bridge CFTypeRef)model.name, &error);
    // 添加联系人电话号码以及该号码对应的标签名
    ABMutableMultiValueRef multi = ABMultiValueCreateMutable(kABPersonPhoneProperty);
    if (![model.mobile isEqualToString:@""]) {
        ABMultiValueAddValueAndLabel(multi, (__bridge CFTypeRef)(model.mobile), (__bridge CFTypeRef)mobileLabel, NULL);
    }
    if (![model.phone isEqualToString:@""]) {
        ABMultiValueAddValueAndLabel(multi, (__bridge CFTypeRef)(model.phone), (__bridge CFTypeRef)telLabel, NULL);
    }
    ABRecordSetValue(record, kABPersonPhoneProperty, multi, &error);
    
    // 联系人头像
    //    ABPersonSetImageData(record,(__bridge CFDataRef)UIImagePNGRepresentation([UIImage imageNamed:icon]),&error);
    ABAddressBookRef addressBook = nil;
    
    //添加字段
    //公司
    //注意：①@"上镜通讯"测试数据，接口返回之后使用公司字段替换 ②公司这里缺少一个判断。数据返回为空的时候不写入
    ABRecordSetValue(record, kABPersonOrganizationProperty, (__bridge CFTypeRef)(@"尚景通讯"), &error);
    //部门
    if (![model.depart isEqualToString:@""]) {
        ABRecordSetValue(record, kABPersonDepartmentProperty, (__bridge CFTypeRef)(model.depart), &error);
    }
    //工作
    if (![model.position isEqualToString:@""]) {
        ABRecordSetValue(record, kABPersonJobTitleProperty, (__bridge CFTypeRef)(model.position), &error);
    }
    
    // 如果为iOS6以上系统，需要等待用户确认是否允许访问通讯录。
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)    {        addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        //等待同意后向下执行
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error)                                                 {                                                     dispatch_semaphore_signal(sema);                                                 });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    // 将新建联系人记录添加如通讯录中
    BOOL success = ABAddressBookAddRecord(addressBook, record, &error);
    if (!success) {
        return NO;
    }else{
        // 如果添加记录成功，保存更新到通讯录数据库中
        success = ABAddressBookSave(addressBook, &error);
        return success ? YES : NO;
    }
}

#pragma mark - setters and getters
- (ExportAddress *)bottomExport {
    if (!_bottomExport) {
        _bottomExport = [[ExportAddress alloc] init];
        // 默认添加一个空数据
        AddressBook *item = [[AddressBook alloc] init];
        item.isDefault = YES;
        item.icon = @"Head_Box";
        [_bottomExport.selectedArray addObject:item];
    }
    return _bottomExport;
}

- (NSMutableArray *)phoneAddressBook {
    if (!_phoneAddressBook) {
        _phoneAddressBook = [[NSMutableArray alloc] init];
    }
    return _phoneAddressBook;
}

- (UIView*)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreen_Height-54, kScreen_Width, 54)];
        _bottomView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        [_bottomView addLineUp:YES andDown:NO];
    }
    return _bottomView;
}

- (UITableView*)bottomTableView {
    if (!_bottomTableView) {
        _bottomTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 54, CGRectGetWidth(_bottomView.bounds)-10-72) style:UITableViewStylePlain];
        _bottomTableView.center = CGPointMake((CGRectGetWidth(_bottomView.bounds)-72-10)/2.0, CGRectGetHeight(_bottomView.bounds)/2.0);
        _bottomTableView.backgroundView = nil;
        _bottomTableView.backgroundColor = [UIColor clearColor];
        _bottomTableView.transform = CGAffineTransformMakeRotation(-M_PI/2);
        _bottomTableView.showsVerticalScrollIndicator = NO;
        _bottomTableView.delegate = self;
        _bottomTableView.dataSource = self;
        _bottomTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_bottomTableView registerClass:[ExportBottomTableViewCell class] forCellReuseIdentifier:kBottomCellIdentifier];
        _bottomTableView.tableFooterView = [[UIView alloc] init];
    }
    return _bottomTableView;
}

- (UILabel*)bottomSelectedLabel {
    if (!_bottomSelectedLabel) {
        _bottomSelectedLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width - 50 - 24, 15, 24, 24)];
        _bottomSelectedLabel.backgroundColor = [UIColor colorWithRed:(CGFloat)34/255.0f green:(CGFloat)192/255.f blue:(CGFloat)100/255.f alpha:1.f];
        _bottomSelectedLabel.textColor = [UIColor whiteColor];
        _bottomSelectedLabel.font = [UIFont systemFontOfSize:14.f];
        _bottomSelectedLabel.textAlignment = NSTextAlignmentCenter;
        _bottomSelectedLabel.layer.cornerRadius = 12.f;
        _bottomSelectedLabel.layer.masksToBounds = YES;
        _bottomSelectedLabel.clipsToBounds = YES;
        _bottomSelectedLabel.hidden = YES;
    }
    return _bottomSelectedLabel;
}

- (UIButton*)bottomConfirmBtn {
    if (!_bottomConfirmBtn) {
        _bottomConfirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _bottomConfirmBtn.frame = CGRectMake(kScreen_Width-50, 0, 50, 54);
        _bottomConfirmBtn.enabled = NO;
        _bottomConfirmBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_bottomConfirmBtn setTitleColor:[[UIColor alloc] initWithRed:34/255.f green:192/255.f blue:100/255.f alpha:1.0]
                                forState:UIControlStateNormal];
        [_bottomConfirmBtn setTitleColor:[[UIColor alloc] initWithRed:34/255.f green:192/255.f blue:100/255.f alpha:0.3]
                                forState:UIControlStateDisabled];
        [_bottomConfirmBtn setTitle:@"完成" forState:UIControlStateNormal];
        [_bottomConfirmBtn addTarget:self action:@selector(confirmButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bottomConfirmBtn;
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
