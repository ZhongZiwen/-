//
//  OpportunityHeaderView.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/14.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "OpportunityHeaderView.h"
#import "CRMDetail.h"
#import "DetailStaffModel.h"
#import "DetailStaffCCell.h"

#define kCCellIdentifier @"DetailStaffCCell"

@interface OpportunityHeaderView ()<UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *oneView;
@property (strong, nonatomic) UIView *twoView;
@property (strong, nonatomic) UIView *threeView;
@property (strong, nonatomic) UIPageControl *pageControl;

@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *infoLabel;
@property (strong, nonatomic) UIImageView *stageView;
@property (strong, nonatomic) UIButton *stageButton;

@property (strong, nonatomic) UILabel *customerLabel;
@property (strong, nonatomic) UIImageView *customerView;
@property (strong, nonatomic) UIButton *customerButton;

@property (strong, nonatomic) UILabel *staffLabel;
@property (strong, nonatomic) UICollectionView *staffsView;

@property (strong, nonatomic) NSArray *staffsArray;
@end

@implementation OpportunityHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addSubview:self.scrollView];
        [self addSubview:self.pageControl];
    }
    return self;
}

- (void)configWithObj:(CRMDetail *)item {
    _nameLabel.text = item.name;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = kCFNumberFormatterDecimalStyle;
    
    NSString *string = [NSString stringWithFormat:@"预期金额：%@元  结单日期：%@", [numberFormatter stringForObjectValue:item.money], [item.billDate stringYearMonthDayForLine]];
    CGFloat height = [string getHeightWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(kScreen_Width - 30, CGFLOAT_MAX)];
    if (height > 20) {
        [_infoLabel setHeight:height];
        _infoLabel.text = [NSString stringWithFormat:@"预期金额：%@元\n结单日期：%@", [numberFormatter stringForObjectValue:item.money], [item.billDate stringYearMonthDayForLine]];
    }else {
        [_infoLabel setHeight:20];
        _infoLabel.text = [NSString stringWithFormat:@"预期金额：%@元  结单日期：%@", [numberFormatter stringForObjectValue:item.money], [item.billDate stringYearMonthDayForLine]];
    }
    
    string = [NSString stringWithFormat:@"销售阶段：%@(%@%%)  >", item.currentStage.value, item.currentStage.rate];
    [_stageView setCenterY:CGRectGetMaxY(_infoLabel.frame) + 10 + CGRectGetHeight(_stageButton.bounds) / 2.0];
    [_stageButton setCenterY:CGRectGetMidY(_stageView.frame)];
    [_stageButton setTitle:string forState:UIControlStateNormal];
    
    string = [NSString stringWithFormat:@"%@  >", item.customer.name];
    [_customerButton setTitle:string forState:UIControlStateNormal];
    
    _staffsArray = [[NSArray alloc] initWithArray:item.staffsArray];
    [_staffsView reloadData];
}

#pragma mark - event response
- (void)stageButtonPress {
    if (self.opportunityStageBlock) {
        self.opportunityStageBlock();
    }
}

- (void)customerButtonPress {
    if (self.customerBlock) {
        self.customerBlock();
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
    if (self.staffsBlock) {
        self.staffsBlock();
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
        [_scrollView addSubview:self.threeView];
        [_scrollView setContentSize:CGSizeMake(3 * kScreen_Width, CGRectGetHeight(self.bounds))];
    }
    return _scrollView;
}

- (UIPageControl*)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.numberOfPages = 3;
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
        [_oneView addSubview:self.infoLabel];
        [_oneView addSubview:self.stageView];
        [_oneView addSubview:self.stageButton];
    }
    return _oneView;
}

- (UIView*)twoView {
    if (!_twoView) {
        _twoView = [[UIView alloc] init];
        [_twoView setX:kScreen_Width];
        [_twoView setWidth:kScreen_Width];
        [_twoView setHeight:CGRectGetHeight(self.bounds)];
        
        [_twoView addSubview:self.customerLabel];
        [_twoView addSubview:self.customerView];
        [_twoView addSubview:self.customerButton];
    }
    return _twoView;
}

- (UIView*)threeView {
    if (!_threeView) {
        _threeView = [[UIView alloc] init];
        [_threeView setX:kScreen_Width * 2];
        [_threeView setWidth:kScreen_Width];
        [_threeView setHeight:CGRectGetHeight(self.bounds)];
        
        [_threeView addSubview:self.staffLabel];
        [_threeView addSubview:self.staffsView];
    }
    return _threeView;
}

- (UILabel*)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        [_nameLabel setX:15];
        [_nameLabel setY:34];
        [_nameLabel setWidth:kScreen_Width - 30];
        [_nameLabel setHeight:20];
        _nameLabel.font = [UIFont systemFontOfSize:16];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.textColor = [UIColor whiteColor];
    }
    return _nameLabel;
}

- (UILabel*)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        [_infoLabel setX:CGRectGetMinX(_nameLabel.frame)];
        [_infoLabel setY:CGRectGetMaxY(_nameLabel.frame) + 10];
        [_infoLabel setWidth:CGRectGetWidth(_nameLabel.bounds)];
        _infoLabel.font = [UIFont systemFontOfSize:14];
        _infoLabel.textColor = [UIColor whiteColor];
        _infoLabel.textAlignment = NSTextAlignmentLeft;
        _infoLabel.numberOfLines = 0;
    }
    return _infoLabel;
}

- (UIImageView*)stageView {
    if (!_stageView) {
        UIImage *image = [UIImage imageNamed:@"sales_step"];
        _stageView = [[UIImageView alloc] initWithImage:image];
        [_stageView setX:15];
        [_stageView setWidth:image.size.width];
        [_stageView setHeight:image.size.height];
    }
    return _stageView;
}

- (UIButton*)stageButton {
    if (!_stageButton) {
        _stageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_stageButton setX:CGRectGetMaxX(_stageView.frame) + 5];
        [_stageButton setWidth:kScreen_Width - CGRectGetMinX(_stageButton.frame) - 15];
        [_stageButton setHeight:20];
        _stageButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _stageButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
        _stageButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _stageButton.titleLabel.textColor = [UIColor whiteColor];
        [_stageButton addTarget:self action:@selector(stageButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _stageButton;
}

- (UILabel*)customerLabel {
    if (!_customerLabel) {
        _customerLabel = [[UILabel alloc] init];
        [_customerLabel setX:15];
        [_customerLabel setY:34];
        [_customerLabel setWidth:kScreen_Width - 30];
        [_customerLabel setHeight:20];
        _customerLabel.font = [UIFont systemFontOfSize:15];
        _customerLabel.textAlignment = NSTextAlignmentLeft;
        _customerLabel.textColor = [UIColor whiteColor];
        _customerLabel.text = @"所属客户";
    }
    return _customerLabel;
}

- (UIImageView*)customerView {
    if (!_customerView) {
        UIImage *image = [UIImage imageNamed:@"customer"];
        _customerView = [[UIImageView alloc] initWithImage:image];
        [_customerView setX:15];
        [_customerView setY:CGRectGetMaxY(_customerLabel.frame) + 30];
        [_customerView setWidth:image.size.width];
        [_customerView setHeight:image.size.height];
    }
    return _customerView;
}

- (UIButton*)customerButton {
    if (!_customerButton) {
        _customerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_customerButton setX:CGRectGetMaxX(_customerView.frame) + 5];
        [_customerButton setHeight:25];
        [_customerButton setWidth:kScreen_Width - CGRectGetMinX(_customerButton.frame) - 15];
        [_customerButton setCenterY:CGRectGetMidY(_customerView.frame)];
        _customerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _customerButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
        _customerButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _customerButton.titleLabel.textColor = [UIColor whiteColor];
        [_customerButton addTarget:self action:@selector(customerButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _customerButton;
}

- (UILabel*)staffLabel {
    if (!_staffLabel) {
        _staffLabel = [[UILabel alloc] init];
        [_staffLabel setX:15];
        [_staffLabel setY:34];
        [_staffLabel setWidth:kScreen_Width - 30];
        [_staffLabel setHeight:20];
        _staffLabel.font = [UIFont systemFontOfSize:15];
        _staffLabel.textAlignment = NSTextAlignmentLeft;
        _staffLabel.textColor = [UIColor whiteColor];
        _staffLabel.text = @"团队成员:";
    }
    return _staffLabel;
}

- (UICollectionView*)staffsView {
    if (!_staffsView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        
        _staffsView = [[UICollectionView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_staffLabel.frame), CGRectGetMaxY(_staffLabel.frame) + 10, kScreen_Width - 2 * CGRectGetMinX(_staffLabel.frame) - 30, 44) collectionViewLayout:layout];
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
