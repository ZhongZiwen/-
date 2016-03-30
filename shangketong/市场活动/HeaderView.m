//
//  HeaderView.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/8.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "HeaderView.h"
#import "DetailStaffModel.h"
#import "DetailStaffCCell.h"
#import "CRMDetail.h"

#define kCCellIdentifier @"DetailStaffCCell"

@interface HeaderView ()<UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) UIView *oneView;
@property (strong, nonatomic) UIView *twoView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UIButton *stateButton;

@property (strong, nonatomic) UILabel *staffName;
@property (strong, nonatomic) UICollectionView *staffsView;
@property (strong, nonatomic) UIButton *accessButton;

@property (copy, nonatomic) NSArray *staffsArray;
@end

@implementation HeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.scrollView];
        [self addSubview:self.pageControl];
    }
    return self;
}

- (void)configWithModel:(CRMDetail *)item {
    _nameLabel.text = item.name;
    _timeLabel.text = [NSString stringWithFormat:@"活动日期：%@ 至 %@", [item.startTime stringYearMonthDayForLine], [item.endTime stringYearMonthDayForLine]];
    
    CGFloat width = [item.activityState.value getWidthWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGRectGetHeight(_stateButton.bounds))];
    [_stateButton setWidth:width + 100];
    [_stateButton setImage:[UIImage imageNamed:@"status"] forState:UIControlStateNormal];
    [_stateButton setTitle:[NSString stringWithFormat:@" 活动状态：%@ >", item.activityState.value] forState:UIControlStateNormal];
    
    _staffsArray = [[NSArray alloc] initWithArray:item.staffsArray];
    [_staffsView reloadData];
}

#pragma mark - event response
- (void)stateButtonPress {
    if (self.stateBtnClickedBlock) {
        self.stateBtnClickedBlock();
    }
}

- (void)accessButtonPress {
    if (self.staffClickedBlock) {
        self.staffClickedBlock();
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
        _scrollView.delegate = self;
        [_scrollView setWidth:CGRectGetWidth(self.bounds)];
        [_scrollView setHeight:CGRectGetHeight(self.bounds)];
        _scrollView.bounces = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        
        [_scrollView addSubview:self.oneView];
        [_scrollView addSubview:self.twoView];
        [_scrollView setContentSize:CGSizeMake(2 * kScreen_Width, CGRectGetHeight(_scrollView.bounds))];
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
        [_oneView setHeight:CGRectGetHeight(self.bounds) - CGRectGetMinY(_oneView.frame)];
        
        [_oneView addSubview:self.nameLabel];
        [_oneView addSubview:self.timeLabel];
        [_oneView addSubview:self.stateButton];
    }
    return _oneView;
}

- (UIView*)twoView {
    if (!_twoView) {
        _twoView = [[UIView alloc] init];
        [_twoView setY:44.0f];
        [_twoView setX:kScreen_Width];
        [_twoView setWidth:kScreen_Width];
        [_twoView setHeight:CGRectGetHeight(self.bounds) - CGRectGetMinY(_twoView.frame)];
        
        [_twoView addSubview:self.staffName];
        [_twoView addSubview:self.staffsView];
        [_twoView addSubview:self.accessButton];
    }
    return _twoView;
}

- (UILabel*)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        [_nameLabel setX:15];
        [_nameLabel setY:34];
        [_nameLabel setWidth:kScreen_Width - 30];
        [_nameLabel setHeight:20];
        _nameLabel.font = [UIFont systemFontOfSize:15];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.textColor = [UIColor whiteColor];
    }
    return _nameLabel;
}

- (UILabel*)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        [_timeLabel setX:CGRectGetMinX(_nameLabel.frame)];
        [_timeLabel setY:CGRectGetMaxY(_nameLabel.frame) + 10];
        [_timeLabel setWidth:CGRectGetWidth(_nameLabel.bounds)];
        [_timeLabel setHeight:20];
        _timeLabel.font = [UIFont systemFontOfSize:13];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _timeLabel;
}

- (UIButton*)stateButton {
    if (!_stateButton) {
        _stateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_stateButton setX:CGRectGetMinX(_nameLabel.frame)];
        [_stateButton setY:CGRectGetMaxY(_timeLabel.frame) + 10];
        [_stateButton setHeight:20];
        _stateButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _stateButton.titleLabel.textColor = [UIColor whiteColor];
        [_stateButton addTarget:self action:@selector(stateButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _stateButton;
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

- (UIButton*)accessButton {
    if (!_accessButton) {
        _accessButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_accessButton setWidth:30];
        [_accessButton setHeight:CGRectGetHeight(_staffsView.bounds)];
        [_accessButton setX:CGRectGetMaxX(_staffsView.frame)];
        [_accessButton setY:CGRectGetMinY(_staffsView.frame)];
        [_accessButton setImage:[UIImage imageNamed:@"activity_edit_gray"] forState:UIControlStateNormal];
        [_accessButton addTarget:self action:@selector(accessButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _accessButton;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
