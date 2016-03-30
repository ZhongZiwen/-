//
//  PhotoBrowserViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/20.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "PhotoBrowserViewController.h"
#import "UIView+Common.h"
#import <POPSpringAnimation.h>
#import "PhotoBrowserTableViewCell.h"
#import "PhotoAssetModel.h"

#define kSpacingBetweenPages   10.0
#define kCellIdentifier @"PhotoBrowserTableViewCell"

@interface PhotoBrowserViewController ()<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *selectButton;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UILabel *numberSelectedLabel;
@property (nonatomic, strong) UIButton *confirmButton;      // 确认按钮

@property (nonatomic, assign) BOOL showFlag;

@property (nonatomic, assign) NSInteger imagesCount;
@property (nonatomic, assign) NSInteger selectedImagesCount;

@property (nonatomic, strong) NSMutableArray *readyCancelArray; // 准备取消选定

/** 设置导航栏样式*/
- (void)setupNavigationBar;

/** 刷新title和button*/
- (void)updateCustomView;

/** 显示或隐藏导航栏动画 showFlag = yes 已显示，要隐藏； no 已隐藏，要显示*/
- (void)animationNavigationBarWithFlag:(BOOL)showFlag;

/** tableview的contentOffset改变后，更新currentPageIndex*/
- (void)updateCurrentPageIndexForContentOffset;
@end

@implementation PhotoBrowserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blackColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupNavigationBar];
    
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(leftButtonItemPress)];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.bottomView];
    [_bottomView addSubview:self.numberSelectedLabel];
    [_bottomView addSubview:self.confirmButton];

    [self updateCustomView];
    
    NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:_currentPageIndex inSection:0];
    [_tableView scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView_M
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_photoType == PhotoBrowserTypeAll) {
        return [_delegate numberOfPhotosInPhotoBrowser:self];
    }else {
        return [_delegate numberOfSelectedPhotosInPhotoBrowser:self];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kScreen_Width + 2 * kSpacingBetweenPages;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak __block typeof(self) weak_self = self;
    PhotoBrowserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.cellTapBlock = ^{
        [self animationNavigationBarWithFlag:weak_self.showFlag];
    };
    
    PhotoAssetModel *photoModel = nil;
    if (_photoType == PhotoBrowserTypeAll) {
        photoModel = [_delegate photoBrowser:self photoAtIndex:indexPath.row];
    }else {
        photoModel = [_delegate photoBrowser:self selectedPhotoAtIndex:indexPath.row];
    }
    [cell configWithModel:photoModel];
    return cell;
}

#pragma mark - public method
- (id)initWithDelegate:(id<PhotoBrowserDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
        
        _currentPageIndex = -1;
        _showFlag = YES;
        _readyCancelArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

- (void)setCurrentPageIndex:(NSInteger)currentPageIndex {
    if (_currentPageIndex == currentPageIndex)
        return;
    
    _currentPageIndex = currentPageIndex;
    self.title = [NSString stringWithFormat:@"%d / %d", _currentPageIndex + 1, _imagesCount];
    
    PhotoAssetModel *model = nil;
    if (_photoType == PhotoBrowserTypeAll) {
        model = [_delegate photoBrowser:self photoAtIndex:_currentPageIndex];
    }else {
        model = [_delegate photoBrowser:self selectedPhotoAtIndex:_currentPageIndex];
    }
    if (model.isSelected) {
        [_selectButton setImage:[UIImage imageNamed:@"multi_graph_select"] forState:UIControlStateNormal];
    }else {
        [_selectButton setImage:[UIImage imageNamed:@"multi_graph_normal"] forState:UIControlStateNormal];
    }
}

- (void)setPhotoType:(PhotoBrowserType)photoType {
    _photoType = photoType;
    
    if ([_delegate respondsToSelector:@selector(numberOfSelectedPhotosInPhotoBrowser:)]) {
        _selectedImagesCount = [_delegate numberOfSelectedPhotosInPhotoBrowser:self];
    }
    
    if (_photoType == PhotoBrowserTypeAll) {
        UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.selectButton];
        self.navigationItem.rightBarButtonItem = rightButtonItem;
        if ([_delegate respondsToSelector:@selector(numberOfPhotosInPhotoBrowser:)]) {
            _imagesCount = [_delegate numberOfPhotosInPhotoBrowser:self];
        }
    }else if (_photoType == PhotoBrowserTypeSelected) {
        UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.selectButton];
        self.navigationItem.rightBarButtonItem = rightButtonItem;
        if ([_delegate respondsToSelector:@selector(numberOfSelectedPhotosInPhotoBrowser:)]) {
            _imagesCount = [_delegate numberOfSelectedPhotosInPhotoBrowser:self];
        }
    }else if (_photoType == PhotoBrowserTypeDelete) {
        UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.deleteButton];
        self.navigationItem.rightBarButtonItem = rightButtonItem;
        if ([_delegate respondsToSelector:@selector(numberOfSelectedPhotosInPhotoBrowser:)]) {
            _imagesCount = [_delegate numberOfSelectedPhotosInPhotoBrowser:self];
        }
    }
}

- (void)setImagesCount:(NSInteger)imagesCount {
    if (_imagesCount == imagesCount)
        return;
    
    _imagesCount = imagesCount;
    
    // 更新title
    self.title = [NSString stringWithFormat:@"%d / %d", _currentPageIndex + 1, _imagesCount];
}

- (void)setSelectedImagesCount:(NSInteger)selectedImagesCount {
    if (_selectedImagesCount == selectedImagesCount)
        return;
    
    _selectedImagesCount = selectedImagesCount;
    
    [self updateCustomView];
}

#pragma mark - private method
- (void)setupNavigationBar {
    [self.navigationController.navigationBar setBarTintColor:nil];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsLandscapePhone];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
}

- (void)updateCustomView {
    
    if (_selectedImagesCount) {
        _confirmButton.enabled = YES;
        
        _numberSelectedLabel.hidden = NO;
        _numberSelectedLabel.transform = CGAffineTransformMakeScale(0.8, 0.8);
        _numberSelectedLabel.text = [NSString stringWithFormat:@"%d", _selectedImagesCount];
        
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

- (void)animationNavigationBarWithFlag:(BOOL)showFlag {
    [self.navigationController setNavigationBarHidden:showFlag animated:YES];
    
    // 显示或隐藏bottomview
    [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
        [_bottomView setY:(showFlag? kScreen_Height : kScreen_Height - 44)];
    } completion:^(BOOL finished) {
        _showFlag = !showFlag;
    }];
}

- (void)updateCurrentPageIndexForContentOffset {
    CGFloat currentContentOffsetY = _tableView.contentOffset.y;
    NSInteger currentIndex = (NSInteger)(currentContentOffsetY / CGRectGetHeight(_tableView.bounds) + 0.5);
    if (currentIndex < 0) {
        currentIndex = 0;
    }
    if (currentIndex > _imagesCount - 1) {
        currentIndex = _imagesCount - 1;
    }
    self.currentPageIndex = currentIndex;
}

#pragma mark - event response
- (void)leftButtonItemPress {
    if (_photoType == PhotoBrowserTypeAll) {
        if (self.updateDataSource) {
            self.updateDataSource();
        }
        [self.navigationController popViewControllerAnimated:YES];
    }else if (_photoType == PhotoBrowserTypeSelected) {
        for (PhotoAssetModel *tempModel in _readyCancelArray) {
            [_delegate photoBrowser:self cancelSelectedPhoto:tempModel];
        }
        if (self.updateDataSource) {
            self.updateDataSource();
        }
        [self.navigationController popViewControllerAnimated:YES];
    }else if (_photoType == PhotoBrowserTypeDelete) {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

- (void)selectButtonPress:(UIButton*)sender {
    PhotoAssetModel *photoModel = nil;
    if (_photoType == PhotoBrowserTypeAll) {
        photoModel = [_delegate photoBrowser:self photoAtIndex:_currentPageIndex];
        if (photoModel.isSelected) {    // 从选中数组中删除
            photoModel.isSelected = NO;
            [_delegate photoBrowser:self cancelSelectedPhoto:photoModel];
            
            // 改变button的图片
            [_selectButton setImage:[UIImage imageNamed:@"multi_graph_normal"] forState:UIControlStateNormal];
        }else {
           // 加判断，是否超过规定的图片数量
            if (_selectedImagesCount >= _selectedMaxCount) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"你最多只能选择%d张照片", _selectedMaxCount] delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles: nil];
                [alertView show];
                return;
            }
            
            photoModel.isSelected = YES;
            [_delegate photoBrowser:self selectPhoto:photoModel];
            
            // 改变button的图片
            [_selectButton setImage:[UIImage imageNamed:@"multi_graph_select"] forState:UIControlStateNormal];
        }
        // 同步_selectedImagesCount
        self.selectedImagesCount = [_delegate numberOfSelectedPhotosInPhotoBrowser:self];
    }else {
        photoModel = [_delegate photoBrowser:self selectedPhotoAtIndex:_currentPageIndex];
        if (photoModel.isSelected) {    // 将准备删除的照片保存在数组中
            photoModel.isSelected = NO;
            [_readyCancelArray addObject:photoModel];
            
            // 改变button的图片
            [_selectButton setImage:[UIImage imageNamed:@"multi_graph_normal"] forState:UIControlStateNormal];
        }else {
            [_readyCancelArray removeObject:photoModel];
            photoModel.isSelected = YES;
            
            // 改变button的图片
            [_selectButton setImage:[UIImage imageNamed:@"multi_graph_select"] forState:UIControlStateNormal];
        }
        
        // 同步_selectedImagesCount
        self.selectedImagesCount = _imagesCount - _readyCancelArray.count;
    }
}

- (void)deleteButtonPress:(UIButton*)sender {
    PhotoAssetModel *photoModel = [_delegate photoBrowser:self selectedPhotoAtIndex:_currentPageIndex];
    NSIndexPath *deleteIndexPath = [NSIndexPath indexPathForRow:_currentPageIndex inSection:0];
    
    [_tableView beginUpdates];
    [_delegate photoBrowser:self cancelSelectedPhoto:photoModel];
    [_tableView deleteRowsAtIndexPaths:@[deleteIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [_tableView endUpdates];
    
    // 同步_selectedImagesCount
    self.selectedImagesCount = [_delegate numberOfSelectedPhotosInPhotoBrowser:self];
    
    // 同步_imagesCount
    self.imagesCount = [_delegate numberOfSelectedPhotosInPhotoBrowser:self];
    
    if (self.selectedImagesCount == 0 && _photoType == PhotoBrowserTypeDelete) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    // 同步_currentPageIndex
    [self updateCurrentPageIndexForContentOffset];
}

- (void)confirmButtonPress {
    if (_photoType == PhotoBrowserTypeAll) {
        if (self.updateDataSource) {
            self.updateDataSource();
        }
        [self dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kAddPhotoImageViewNotification object:nil];
        }];
    }else if (_photoType == PhotoBrowserTypeSelected) {
        for (PhotoAssetModel *tempModel in _readyCancelArray) {
            [_delegate photoBrowser:self cancelSelectedPhoto:tempModel];
        }
        if (self.updateDataSource) {
            self.updateDataSource();
        }
        [self dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kAddPhotoImageViewNotification object:nil];
        }];
    }else if (_photoType == PhotoBrowserTypeDelete) {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // 隐藏导航栏和底部视图
//    [self animationNavigationBarWithFlag:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateCurrentPageIndexForContentOffset];
}

#pragma mark - setters and getters
- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[PhotoBrowserTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.pagingEnabled = YES;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.showsVerticalScrollIndicator = NO;
        
        CGAffineTransform rotateTable = CGAffineTransformMakeRotation(-M_PI_2);
        _tableView.transform = rotateTable;
        _tableView.frame = CGRectMake(-kSpacingBetweenPages, 0, kScreen_Width + 2 * kSpacingBetweenPages, kScreen_Height);
    }
    return _tableView;
}

- (UIButton*)deleteButton {
    if (!_deleteButton) {
        UIImage *image = [UIImage imageNamed:@"multi_graph_gallery_delete"];
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        [_deleteButton setImage:image forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(deleteButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}

- (UIButton*)selectButton {
    if (!_selectButton) {
        UIImage *image = [UIImage imageNamed:@"multi_graph_normal"];
        _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectButton.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        [_selectButton addTarget:self action:@selector(selectButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectButton;
}

- (UIView*)bottomView {
    
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreen_Height - 44, kScreen_Width, 44)];
        _bottomView.backgroundColor = [UIColor colorWithWhite:0.2f alpha:0.9f];
    }
    return _bottomView;
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
//        _numberSelectedLabel.hidden = YES;
    }
    return _numberSelectedLabel;
}

- (UIButton*)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmButton.frame = CGRectMake(kScreen_Width-50, 0, 50, 44);
        _confirmButton.enabled = false;
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
