//
//  PhotoBrowserController.m
//  
//
//  Created by sungoin-zbs on 15/12/27.
//
//

#import "PhotoBrowserController.h"
#import "PhotoBrowserCell.h"
#import "Record.h"

#define kSpacingBetweenPages   10.0
#define kCellIdentifier @"PhotoBrowserCell"

@interface PhotoBrowserController ()<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIView *bottomView;
@property (strong, nonatomic) UILabel *bottomLabel;
@property (strong, nonatomic) UIButton *confirmButton;

@property (assign, nonatomic) BOOL showFlag;

@property (assign, nonatomic) NSInteger imagesCount;

/** 设置导航栏样式*/
- (void)setupNavigationBar;
/** 显示或隐藏导航栏动画 showFlag = yes 已显示，要隐藏； no 已隐藏，要显示*/
- (void)animationNavigationBarWithFlag:(BOOL)showFlag;
/** tableview的contentOffset改变后，更新currentPageIndex*/
- (void)updateCurrentPageIndexForContentOffset;
@end

@implementation PhotoBrowserController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self setupNavigationBar];
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithIcon:@"nav_back" showBadge:YES target:self action:@selector(leftButtonPress)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithIcon:@"multi_graph_gallery_delete" showBadge:YES target:self action:@selector(deleteButtonPress)];
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.bottomView];
    [_bottomView addSubview:self.bottomLabel];
    [_bottomView addSubview:self.confirmButton];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _showFlag = YES;
    
    [self updateBottomView];
    
    NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:_curIndex inSection:0];
    [_tableView scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - event response
- (void)leftButtonPress {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)deleteButtonPress {
    
    NSLog(@"curIndex = %d", _curIndex);
    
    // 删除数据源数据
    [_delegate photoBrowser:self deleteItemAtRow:_curIndex];
    NSIndexPath *deleteIndexPath = [NSIndexPath indexPathForRow:_curIndex inSection:0];
    
    [_tableView deleteRowsAtIndexPaths:@[deleteIndexPath] withRowAnimation:UITableViewRowAnimationBottom];
    
    _imagesCount = [_delegate numberOfRowsInPhotoBrowser:self];
    
    if (!_imagesCount) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    [self updateCurrentPageIndexForContentOffset];
}

- (void)confirmButtonPress {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - private method
- (void)setupNavigationBar {
    [self.navigationController.navigationBar setBarTintColor:nil];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsLandscapePhone];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
}

- (void)updateBottomView {
    _imagesCount = [_delegate numberOfRowsInPhotoBrowser:self];
    
    self.title = [NSString stringWithFormat:@"%d / %d", _curIndex + 1, _imagesCount];
    
    _bottomLabel.transform = CGAffineTransformMakeScale(0.8, 0.8);
    _bottomLabel.text = [NSString stringWithFormat:@"%d", _imagesCount];
    
    [UIView animateWithDuration:0.3 animations:^{
        _bottomLabel.transform = CGAffineTransformMakeScale(1.125, 1.125);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            _bottomLabel.transform = CGAffineTransformMakeScale(0.8, 0.8);
        } completion:nil];
    }];
}

#pragma mark - UITableView_M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_delegate numberOfRowsInPhotoBrowser:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kScreen_Width + 2 * kSpacingBetweenPages;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PhotoBrowserCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    RecordImage *item = [_delegate photoBrowser:self itemAtRow:indexPath.row];
    [cell configWithItem:item];
    cell.imageTapBlock = ^{
        [self animationNavigationBarWithFlag:_showFlag];
    };
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // 隐藏导航栏和底部视图
    //    [self animationNavigationBarWithFlag:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateCurrentPageIndexForContentOffset];
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
    self.curIndex = currentIndex;
}

#pragma mark - setters and getters
- (void)setCurIndex:(NSInteger)curIndex {
    _curIndex = curIndex;
    
    self.title = [NSString stringWithFormat:@"%d / %d", _curIndex + 1, _imagesCount];
}

- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[PhotoBrowserCell class] forCellReuseIdentifier:kCellIdentifier];
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

- (UIView*)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreen_Height - 44, kScreen_Width, 44)];
        _bottomView.backgroundColor = [UIColor colorWithWhite:0.2f alpha:0.9f];
    }
    return _bottomView;
}

- (UILabel*)bottomLabel {
    if (!_bottomLabel) {
        _bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width - 50 - 24, 10, 24, 24)];
        _bottomLabel.backgroundColor = [UIColor colorWithRed:(CGFloat)34/255.0f green:(CGFloat)192/255.f blue:(CGFloat)100/255.f alpha:1.f];
        _bottomLabel.textColor = [UIColor whiteColor];
        _bottomLabel.font = [UIFont systemFontOfSize:14.f];
        _bottomLabel.textAlignment = NSTextAlignmentCenter;
        _bottomLabel.layer.cornerRadius = 12.f;
        _bottomLabel.layer.masksToBounds = YES;
        _bottomLabel.clipsToBounds = YES;
    }
    return _bottomLabel;
}

- (UIButton*)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmButton.frame = CGRectMake(kScreen_Width-50, 0, 50, 44);
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
