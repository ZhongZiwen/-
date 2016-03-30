//
//  PhotoAssetLibraryViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "PhotoAssetLibraryViewController.h"
#import "UIView+Common.h"
#import "UIViewController+NavDropMenu.h"
#import <POPSpringAnimation.h>
#import "PhotoAssetLibraryCell.h"
#import "PhotoAssetModel.h"
#import "PhotoBrowserViewController.h"

#define kCellIdentifier @"PhotoAssetLibraryCell"
@interface PhotoAssetLibraryViewController ()<UITableViewDataSource, UITableViewDelegate, PhotoBrowserDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *numberSelectedLabel;
@property (nonatomic, strong) UIButton *confirmButton;      // 确认按钮

// 获取某个相簿的全部照片资源
- (void)getPhotosFromGroupWithIndex:(NSInteger)index;

// 配置确定按钮的title
- (void)configCustomView;

// tableview滚动到底部
- (void)scrollToBottom;
@end

@implementation PhotoAssetLibraryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = kView_BG_Color;
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(leftButtonPress)];
    self.navigationItem.leftBarButtonItem = leftButton;
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"预览" style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonPress)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    [self.view addSubview:self.tableView];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreen_Height - 44, kScreen_Width, 44)];
    bottomView.backgroundColor = [UIColor colorWithWhite:0.2f alpha:0.9f];
    [self.view addSubview:bottomView];
    
    [bottomView addSubview:self.numberSelectedLabel];
    [bottomView addSubview:self.confirmButton];
    
    _assetManager = [[PhotoAssetManager alloc] init];
    
    __weak typeof(self) weak_self = self;
    [_assetManager getALAssetsGroupAllComplete:^{
        [weak_self customDownMenuWithType:TableViewCellTypeAssetsLabrary andSource:weak_self.assetManager.assetsGroupArray andDefaultIndex:0 andBlock:^(NSInteger index) {
            [weak_self getPhotosFromGroupWithIndex:index];
        }];
        
        // 默认显示相册交卷照片
        [weak_self getPhotosFromGroupWithIndex:0];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - event response
- (void)confirmButtonPress {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.confirmBtnClickedBlock) {
            self.confirmBtnClickedBlock(_assetManager.selectedArray);
        }
    }];
}

- (void)leftButtonPress {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)rightButtonPress {
    if (_assetManager.selectedArray.count) {
        __weak typeof(self) weak_self = self;
        PhotoBrowserViewController *photoBrowserController = [[PhotoBrowserViewController alloc] initWithDelegate:self];
        photoBrowserController.photoType = PhotoBrowserTypeSelected;
        photoBrowserController.currentPageIndex = 0;
        photoBrowserController.updateDataSource = ^{
            [weak_self updateDataSource];
            if (self.confirmBtnClickedBlock) {
                self.confirmBtnClickedBlock(_assetManager.selectedArray);
            }
        };
        [self.navigationController pushViewController:photoBrowserController animated:YES];
    }
}

#pragma mark - public method
- (void)updateDataSource {
    [self configCustomView];
    [_tableView reloadData];
}

- (void)autoAddCameraPhoto {
    __weak typeof(self) weak_self = self;
   
    // 默认显示相册交卷照片
    [weak_self customDownMenuWithType:TableViewCellTypeAssetsLabrary andSource:weak_self.assetManager.assetsGroupArray andDefaultIndex:0 andBlock:^(NSInteger index) {
        [weak_self getPhotosFromGroupWithIndex:index];
    }];
    
    NSURL *url = [[_assetManager.assetsGroupArray objectAtIndex:0] objectForKey:kGroupURL];
    NSString *groupName = [[_assetManager.assetsGroupArray objectAtIndex:0] objectForKey:kGroupLabelText];
    [_assetManager retrieveAssetGroupByURL:url andGroupName:groupName complete:^{
        if (_assetManager.selectedArray.count >= self.maxCount) {
            [weak_self updateDataSource];
            [weak_self scrollToBottom];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"你最多只能选择%d张照片", self.maxCount] delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles: nil];
            [alertView show];
            return;
        }else{
            [weak_self.assetManager selecteCameraPhoto];
            [weak_self updateDataSource];
            [weak_self scrollToBottom];
        }
    }];
}

#pragma mark - private method
- (void)getPhotosFromGroupWithIndex:(NSInteger)index {
    __weak typeof(self) weak_self = self;
    NSURL *url = [[_assetManager.assetsGroupArray objectAtIndex:index] objectForKey:kGroupURL];
    NSString *groupName = [[_assetManager.assetsGroupArray objectAtIndex:index] objectForKey:kGroupLabelText];
    [_assetManager retrieveAssetGroupByURL:url andGroupName:groupName complete:^{
        [weak_self.tableView reloadData];
        [weak_self scrollToBottom];
    }];
}

- (void)configCustomView {
    if (_assetManager.selectedArray.count) {
        _confirmButton.enabled = YES;
        
        _numberSelectedLabel.hidden = NO;
        _numberSelectedLabel.transform = CGAffineTransformMakeScale(0.8, 0.8);
        _numberSelectedLabel.text = [NSString stringWithFormat:@"%d", _assetManager.selectedArray.count];
        
        [UIView animateWithDuration:0.3 animations:^{
            _numberSelectedLabel.transform = CGAffineTransformMakeScale(1.125, 1.125);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 animations:^{
                _numberSelectedLabel.transform = CGAffineTransformMakeScale(0.8, 0.8);
            } completion:nil];
        }];
        
        return;
    }
    
    _confirmButton.enabled = NO;
    _numberSelectedLabel.hidden = YES;
    _numberSelectedLabel.text = @"0";
}

- (void)scrollToBottom {
    NSInteger rowCount = 0;
    if (_assetManager.groupPhotoaArray.count % 3 == 0 ) {
        rowCount = _assetManager.groupPhotoaArray.count / 3;
    }else {
        rowCount = _assetManager.groupPhotoaArray.count / 3 + 1;
    }
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rowCount - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

#pragma mark - PhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(PhotoBrowserViewController *)photoBrowser {
    return _assetManager.groupPhotoaArray.count;
}

- (NSUInteger)numberOfSelectedPhotosInPhotoBrowser:(PhotoBrowserViewController *)photoBrowser {
    return _assetManager.selectedArray.count;
}

- (PhotoAssetModel*)photoBrowser:(PhotoBrowserViewController *)photoBrowser photoAtIndex:(NSUInteger)index {
    PhotoAssetModel *photoModel = _assetManager.groupPhotoaArray[index];
    return photoModel;
}

- (PhotoAssetModel*)photoBrowser:(PhotoBrowserViewController *)photoBrowser selectedPhotoAtIndex:(NSUInteger)index {
    PhotoAssetModel *photoModel = _assetManager.selectedArray[index];
    return photoModel;
}

- (void)photoBrowser:(PhotoBrowserViewController *)photoBrowser cancelSelectedPhoto:(PhotoAssetModel *)photoModel {
    if (photoBrowser.photoType == PhotoBrowserTypeSelected) {
        [_assetManager deleteObjFromGroupPhotoArrayWith:photoModel];
    }
    [_assetManager deleteObjFromSelectedArrayWith:photoModel];
}

- (void)photoBrowser:(PhotoBrowserViewController *)photoBrowser selectPhoto:(PhotoAssetModel *)photoModel {
    [_assetManager.selectedArray addObject:photoModel];
}

#pragma mark - UITableView_M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (_assetManager.groupPhotoaArray && _assetManager.groupPhotoaArray.count > 0) {
        if (_assetManager.groupPhotoaArray.count % 3 == 0 ) {
            return _assetManager.groupPhotoaArray.count / 3;
        }else {
            return _assetManager.groupPhotoaArray.count / 3 + 1;
        }
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [PhotoAssetLibraryCell cellHeight];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PhotoAssetLibraryCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    __weak __block typeof(self) weak_self = self;
    cell.assetLibraryController = self;
    // 选择照片或取消照片
    cell.selectButtonPress = ^(NSInteger index, BOOL isSelected) {
        PhotoAssetModel *model = [weak_self.assetManager.groupPhotoaArray objectAtIndex:index];
        
        model.isSelected = isSelected;
        if (isSelected) {
            [weak_self.assetManager.selectedArray addObject:model];
        }else {
            [weak_self.assetManager deleteObjFromSelectedArrayWith:model];
        }
        [weak_self configCustomView];
    };
    
    // 跳转预览全部图片资源
    cell.imageViewTap = ^(NSInteger tag) {
        PhotoBrowserViewController *photoBrowser = [[PhotoBrowserViewController alloc] initWithDelegate:self];
        photoBrowser.photoType = PhotoBrowserTypeAll;
        photoBrowser.currentPageIndex = tag;
        photoBrowser.selectedMaxCount = _maxCount;
        photoBrowser.updateDataSource = ^{
            [weak_self updateDataSource];
        };
        [self.navigationController pushViewController:photoBrowser animated:YES];
    };
    
    PhotoAssetModel *firstAsset = _assetManager.groupPhotoaArray[indexPath.row * 3];
    
    cell.imageView0.image = [UIImage imageWithCGImage:[firstAsset.asset thumbnail]];
    cell.imageView0.tag = firstAsset.index;
    cell.button0.tag = firstAsset.index;
    cell.button0.selected = firstAsset.isSelected;
    
    if (indexPath.row * 3 + 1 < _assetManager.groupPhotoaArray.count) {
        PhotoAssetModel *secondAsset = _assetManager.groupPhotoaArray[indexPath.row * 3 + 1];
        cell.imageView1.hidden = NO;
        cell.imageView1.image = [UIImage imageWithCGImage:[secondAsset.asset thumbnail]];
        cell.imageView1.tag = secondAsset.index;
        cell.button1.hidden = NO;
        cell.button1.tag = secondAsset.index;
        cell.button1.selected = secondAsset.isSelected;
    }else {
        cell.imageView1.hidden = YES;
        cell.button1.hidden = YES;
    }
    
    if (indexPath.row * 3 + 2 < _assetManager.groupPhotoaArray.count) {
        PhotoAssetModel *thirdAsset = _assetManager.groupPhotoaArray[indexPath.row * 3 + 2];
        cell.imageView2.hidden = NO;
        cell.imageView2.image = [UIImage imageWithCGImage:[thirdAsset.asset thumbnail]];
        cell.imageView2.tag = thirdAsset.index;
        cell.button2.hidden = NO;
        cell.button2.tag = thirdAsset.index;
        cell.button2.selected = thirdAsset.isSelected;
    }else {
        cell.imageView2.hidden = YES;
        cell.button2.hidden = YES;
    }
    
    return cell;
}

#pragma mark - setters and getters
- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height - 44) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[PhotoAssetLibraryCell class] forCellReuseIdentifier:kCellIdentifier];
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    return _tableView;
}

- (UILabel*)numberSelectedLabel {
    if (!_numberSelectedLabel) {
        _numberSelectedLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width - 50 - 24, 10, 24, 24)];
        _numberSelectedLabel.backgroundColor = [UIColor colorWithRed:(CGFloat)34/255.0f green:(CGFloat)192/255.f blue:(CGFloat)100/255.f alpha:1.f];
        _numberSelectedLabel.textColor = [UIColor whiteColor];
        _numberSelectedLabel.font = [UIFont systemFontOfSize:14.f];
        _numberSelectedLabel.textAlignment = NSTextAlignmentCenter;
        _numberSelectedLabel.layer.cornerRadius = 12.f;
        _numberSelectedLabel.layer.masksToBounds = YES;
        _numberSelectedLabel.clipsToBounds = YES;
        _numberSelectedLabel.hidden = YES;
    }
    return _numberSelectedLabel;
}

- (UIButton*)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmButton.frame = CGRectMake(kScreen_Width-50, 0, 50, 44);
        _confirmButton.enabled = NO;
        _confirmButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_confirmButton setTitleColor:[[UIColor alloc] initWithRed:34/255.f green:192/255.f blue:100/255.f alpha:1.0]
                             forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[[UIColor alloc] initWithRed:34/255.f green:192/255.f blue:100/255.f alpha:0.3]
                             forState:UIControlStateDisabled];
        [_confirmButton setTitle:@"完成" forState:UIControlStateNormal];
        [_confirmButton addTarget:self action:@selector(confirmButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
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
