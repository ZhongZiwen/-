//
//  SKTSelectMemberPreController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/8/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SKTSelectMemberPreController.h"
#import "NSString+Common.h"
#import <UIImageView+WebCache.h>
#import <POPSpringAnimation.h>
#import "SKTFilterValue.h"
#import "InfoViewController.h"
#import "SKTSelectMemberController.h"
//#import "AddressSelectMorePreLayout.h"
//#import "AddressSelectMorePreCell.h"

#define kSpaceWidth 15
#define kImageViewWidth (kScreen_Width - 6 * kSpaceWidth)/5.0
#define kCellIdentifier @"AddressSelectMorePreCell"

@interface SKTSelectMemberPreController ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) UICollectionView *collectionView;
@property (assign, nonatomic) BOOL isDelete;
@end

@implementation SKTSelectMemberPreController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    
}

#define angelToRandian(x)  ((x)/180.0*M_PI)
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 创建布局
//    AddressSelectMorePreLayout *layout = [[AddressSelectMorePreLayout alloc] init];
//    
//    // 创建collectionView
//    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
//    collectionView.backgroundColor = kView_BG_Color;
//    collectionView.dataSource = self;
//    collectionView.delegate = self;
//    [collectionView registerClass:[AddressSelectMorePreCell class] forCellWithReuseIdentifier:kCellIdentifier];
//    [self.view addSubview:collectionView];
//    _collectionView = collectionView;
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
    return _sourceArray.count + 2;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//    AddressSelectMorePreCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
//    if (indexPath.item < _sourceArray.count) {
//        SKTFilterValue *valueItem = _sourceArray[indexPath.item];
//        [cell configWithFilterItem:valueItem isDelete:_isDelete];
//    }else {
//        NSArray *array = @[@"add-normal", @"minus-normal"];
//        [cell configWithImageStr:array[indexPath.item - _sourceArray.count]];
//    }
//    return cell;
    return nil;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.item == _sourceArray.count + 1) {
        self.isDelete = !_isDelete;
        return;
    }
    
    // 添加联系人操作
    if (indexPath.item == _sourceArray.count) {
        
        SKTSelectMemberController *selectController = [[SKTSelectMemberController alloc] init];
        selectController.title = @"通讯录";
        selectController.selectedArray = _sourceArray;
        selectController.valueBlock = ^(NSArray *selectArray) {
            for (AddressSelectModel *selectModel in selectArray) {
                SKTFilterValue *value = [SKTFilterValue initWithModel:selectModel];
                [_sourceArray addObject:value];
            }

            [self.collectionView reloadData];
        };
        [self.navigationController pushViewController:selectController animated:YES];
        return;
    }
    
    // 删除或者进入个人详情操作
    if (_isDelete) {  // 删除
        
        // 删除数据
        [_sourceArray removeObjectAtIndex:indexPath.item];
        
        // 直接将cell删除
        [_collectionView deleteItemsAtIndexPaths:@[indexPath]];
        
        return;
    }
    
    // 个人资料
    SKTFilterValue *value = _sourceArray[indexPath.item];
    InfoViewController *controller = [[InfoViewController alloc] init];
    controller.title = @"个人信息";
    if ([appDelegateAccessor.moudle.userId integerValue] == [value.m_id integerValue]) {
        controller.infoTypeOfUser = InfoTypeMyself;
    }else{
        controller.infoTypeOfUser = InfoTypeOthers;
        controller.userId = [value.m_id integerValue];
    }
    [self.navigationController pushViewController:controller animated:YES];
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
