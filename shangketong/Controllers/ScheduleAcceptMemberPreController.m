//
//  ScheduleAcceptMemberPreController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/8/17.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ScheduleAcceptMemberPreController.h"
#import "ExportAddress.h"
#import "AddressBook.h"
#import "CollectionViewLayout.h"
#import "CollectionViewCell.h"
#import "ExportAddressViewController.h"
#import "InfoViewController.h"

#define kSpaceWidth 10
#define kImageViewWidth (kScreen_Width - 6 * kSpaceWidth)/5.0
#define kCellIdentifier @"CollectionViewCell"

@interface ScheduleAcceptMemberPreController ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) UICollectionView *collectionView;
@property (assign, nonatomic) BOOL isDelete;
@end

@implementation ScheduleAcceptMemberPreController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    self.automaticallyAdjustsScrollViewInsets = NO;

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.refreshBlock) {
        self.refreshBlock();
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    // 创建布局
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    // 创建collectionView
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    [collectionView setY:64.0f];
    [collectionView setWidth:kScreen_Width];
    [collectionView setHeight:kScreen_Height - CGRectGetMinY(collectionView.frame)];
    collectionView.backgroundColor = kView_BG_Color;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:kCellIdentifier];
    [self.view addSubview:collectionView];
    _collectionView = collectionView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _sourceModel.selectedArray.count + 2;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    if (indexPath.item < _sourceModel.selectedArray.count) {
        AddressBook *item = _sourceModel.selectedArray[indexPath.item];
        [cell configWithAddressBook:item isDelete:_isDelete];
    }else {
        NSArray *array = @[@"add-normal", @"minus-normal"];
        [cell configWithImageStr:array[indexPath.item - _sourceModel.selectedArray.count]];
    }
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(kImageViewWidth, kImageViewWidth + 20);
}

// 定义每个UICollectionView的间距
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

// 定义每个UICollectionView纵向的间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.item == _sourceModel.selectedArray.count + 1) {
        self.isDelete = !_isDelete;
        [_collectionView reloadData];
        return;
    }
    
    // 添加联系人操作
    if (indexPath.item == _sourceModel.selectedArray.count) {
        
        @weakify(self);
        ExportAddressViewController *addController = [[ExportAddressViewController alloc] init];
        addController.title = @"通讯录";
        addController.selectedArray = _sourceModel.selectedArray;
        addController.valueBlock = ^(NSArray *souceArray) {
            @strongify(self);
            [self sendRequestWithArray:souceArray delete:nil];
        };
        [self.navigationController pushViewController:addController animated:YES];
        return;
    }
    
    // 删除或者进入个人详情操作
    if (_isDelete) {  // 删除
        
        if (_sourceModel.selectedArray.count == 1) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"参与人不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alertView show];
            return;
        }

        // 请求服务器删除数据
        [self sendRequestWithArray:nil delete:_sourceModel.selectedArray[indexPath.row]];

        // 删除数据
        [_sourceModel.selectedArray removeObjectAtIndex:indexPath.item];
        
        // 直接将cell删除
        [_collectionView deleteItemsAtIndexPaths:@[indexPath]];
        
        return;
    }
    
    // 个人资料
    AddressBook *item = _sourceModel.selectedArray[indexPath.row];
    InfoViewController *infoController = [[InfoViewController alloc] init];
    infoController.title = @"个人信息";
    if ([appDelegateAccessor.moudle.userId isEqualToString:[NSString stringWithFormat:@"%@", item.id]]) {
        infoController.infoTypeOfUser = InfoTypeMyself;
    }
    else {
        infoController.infoTypeOfUser = InfoTypeOthers;
        infoController.userId = [item.id integerValue];
    }
    [self.navigationController pushViewController:infoController animated:YES];
}

- (void)sendRequestWithArray:(NSArray*)array delete:(AddressBook*)item {
    NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
    [tempDict addEntriesFromDictionary:_scheduleSourceDict];
    
    NSString *addString = @"";
    for (int i = 0; i < array.count; i ++) {
        AddressBook *item = array[i];
        if (i) {
            addString = [NSString stringWithFormat:@"%@,%@", addString, item.id];
        }
        else {
            addString = [NSString stringWithFormat:@"%@", item.id];
        }
    }
    [tempDict setObject:addString forKey:@"addStaffIds"];
    [tempDict setObject:(item ? item.id : @"") forKey:@"delStaffIds"];
    
    [self.view beginLoading];
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, kNetPath_Schedule_Update] params:tempDict success:^(id responseObj) {
        [self.view endLoading];
        [_sourceModel.selectedArray addObjectsFromArray:array];
        [_collectionView reloadData];
    } failure:^(NSError *error) {
        [self.view endLoading];
        kShowHUD(@"添加参与人失败，请重试！");
    }];
}

#pragma mark - setters and getters
- (void)setIsDelete:(BOOL)isDelete {
    
    _isDelete = isDelete;
    
    [_collectionView reloadData];
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
