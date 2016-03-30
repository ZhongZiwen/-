//
//  CustomerHeaderView.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/28.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "CustomerHeaderView.h"
#import "DetailStaffModel.h"
#import "DetailStaffCCell.h"
#import "CRMDetail.h"

#define kCCellIdentifier @"DetailStaffCCell"

@interface CustomerHeaderView ()<UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *oneView;
@property (strong, nonatomic) UIView *twoView;
@property (strong, nonatomic) UIPageControl *pageControl;

@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UIButton *phoneButton;
@property (strong, nonatomic) UIButton *positionButton;
@property (strong, nonatomic) UILabel *staffName;
@property (strong, nonatomic) UICollectionView *staffsView;

@property (strong, nonatomic) NSArray *staffsArray;
@end

@implementation CustomerHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addSubview:self.scrollView];
        [self addSubview:self.pageControl];
    }
    return self;
}

- (void)configWithObj:(CRMDetail*)item {
    
    _nameLabel.text = item.name;
    
    [_phoneButton setImage:[UIImage imageNamed:(item.phone ? @"tel" : @"tel_disable")] forState:UIControlStateNormal];
    [_phoneButton setEnabled:item.phone ? YES : NO];
    
    [_positionButton setImage:[UIImage imageNamed:(item.position ? @"location" : @"location_disable")] forState:UIControlStateNormal];
    [_positionButton setEnabled:item.position ? YES : NO];
    
    _staffsArray = [[NSArray alloc] initWithArray:item.staffsArray];
    [_staffsView reloadData];
}

#pragma mark - event response
- (void)phoneButtonPress {
    if (self.phoneBtnClickedBlock) {
        self.phoneBtnClickedBlock();
    }
}

- (void)positionButtonPress {
    if (self.positionBtnClickedBlock) {
        self.positionBtnClickedBlock();
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // 根据当前的x坐标和宽度计算出当前页数
    _pageControl.currentPage = (int)scrollView.contentOffset.x/kScreen_Width;
}

#pragma mark - UICollectionView_M
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _staffsArray.count;
}

// 定义每个UICollectionViewItem 的大小（返回CGSize：宽度和高度）
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(30, 30);
}

// 定义每个UICollectionViewItem 的间距（返回UIEdgeInsets：上、左、下、右）
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(7, 5, 7, 5);
}

// 定义每个UICollectionViewItem 纵向的间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DetailStaffCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCCellIdentifier forIndexPath:indexPath];
    DetailStaffModel *item = _staffsArray[indexPath.item];
    [cell configWithModel:item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.staffClickedBlock) {
        self.staffClickedBlock();
    }
}

#pragma mark - setters and getters
- (UIScrollView*)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.delegate = self;
        [_scrollView setWidth:CGRectGetWidth(self.bounds)];
        [_scrollView setHeight:CGRectGetHeight(self.bounds)];
        _scrollView.bounces = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        
        [_scrollView addSubview:self.oneView];
        [_scrollView addSubview:self.twoView];
        [_scrollView setContentSize:CGSizeMake(2 * kScreen_Width, CGRectGetHeight(self.bounds))];
    }
    return _scrollView;
}

- (UIPageControl*)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.numberOfPages = 2;
        _pageControl.currentPage = 0;
        _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
        _pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:0.95 alpha:0.8];
        [_pageControl sizeToFit];
        [_pageControl setCenterX:CGRectGetMidX(self.frame)];
        [_pageControl setY:CGRectGetHeight(self.bounds) - CGRectGetHeight(_pageControl.bounds)];
    }
    return _pageControl;
}

- (UIView*)oneView {
    if (!_oneView) {
        _oneView = [[UIView alloc] init];
        [_oneView setWidth:kScreen_Width];
        [_oneView setHeight:CGRectGetHeight(self.bounds)];
        
        [_oneView addSubview:self.nameLabel];
        [_oneView addSubview:self.phoneButton];
        [_oneView addSubview:self.positionButton];
    }
    return _oneView;
}

- (UIView*)twoView {
    if (!_twoView) {
        _twoView = [[UIView alloc] init];
        [_twoView setX:kScreen_Width];
        [_twoView setWidth:kScreen_Width];
        [_twoView setHeight:CGRectGetHeight(self.bounds)];
        
        [_twoView addSubview:self.staffName];
        [_twoView addSubview:self.staffsView];
    }
    return _twoView;
}

- (UILabel*)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        [_nameLabel setWidth:kScreen_Width - 30];
        [_nameLabel setHeight:20];
        [_nameLabel setCenterX:kScreen_Width / 2];
        [_nameLabel setCenterY:44];
        _nameLabel.font = [UIFont systemFontOfSize:16];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nameLabel;
}

- (UIButton*)phoneButton {
    if (!_phoneButton) {
        UIImage *image = [UIImage imageNamed:@"tel_disable"];
        _phoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_phoneButton setWidth:image.size.width];
        [_phoneButton setHeight:image.size.height];
        [_phoneButton setCenterX:kScreen_Width / 3.0];
        [_phoneButton setCenterY:CGRectGetHeight(self.bounds) - 50];
        [_phoneButton addTarget:self action:@selector(phoneButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _phoneButton;
}

- (UIButton*)positionButton {
    if (!_positionButton) {
        _positionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_positionButton setY:CGRectGetMinY(_phoneButton.frame)];
        [_positionButton setWidth:CGRectGetWidth(_phoneButton.bounds)];
        [_positionButton setHeight:CGRectGetHeight(_phoneButton.bounds)];
        [_positionButton setCenterX:kScreen_Width * 2.0 / 3.0];
        [_positionButton addTarget:self action:@selector(positionButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _positionButton;
}

- (UILabel*)staffName {
    if (!_staffName) {
        _staffName = [[UILabel alloc] init];
        [_staffName setX:15];
        [_staffName setY:34];
        [_staffName setWidth:kScreen_Width - 30];
        [_staffName setHeight:20];
        _staffName.font = [UIFont systemFontOfSize:15];
        _staffName.textAlignment = NSTextAlignmentLeft;
        _staffName.textColor = [UIColor whiteColor];
        _staffName.text = @"团队成员:";
    }
    return _staffName;
}

- (UICollectionView*)staffsView {
    if (!_staffsView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        
        _staffsView = [[UICollectionView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_staffName.frame), CGRectGetMaxY(_staffName.frame) + 10, kScreen_Width - 2 * CGRectGetMinX(_staffName.frame) - 30, 44) collectionViewLayout:layout];
        [_staffsView setBackgroundView:nil];
        [_staffsView setBackgroundColor:[UIColor clearColor]];
        [_staffsView registerClass:[DetailStaffCCell class] forCellWithReuseIdentifier:kCCellIdentifier];
        _staffsView.showsHorizontalScrollIndicator = NO;
        _staffsView.showsVerticalScrollIndicator = NO;
        _staffsView.dataSource = self;
        _staffsView.delegate = self;
    }
    return _staffsView;
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
