//
//  SectionHeaderView.m
//  Test
//
//  Created by 钟必胜 on 15/10/1.
//  Copyright (c) 2015年 wendell. All rights reserved.
//

#import "SectionHeaderView.h"
#import "SectionCollectionLayout.h"
#import "SectionCollectionCell.h"
#import "CRMDetail.h"

#define kCellIdentifier @"SectionCollectionCell"

@interface SectionHeaderView ()

@end

@implementation SectionHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor iOS7lightGrayColor];
        
        [self addSubview:self.collectionView];
    }
    return self;
}

#pragma mark -public method
- (void)configDataSourceWithDetailItem:(CRMDetail *)item {
    if (_type == SectionHeaderViewTypeActivity) {
        _titlesArray = [NSMutableArray arrayWithObjects:@"销售线索", @"日程任务", @"审批", @"文档", nil];
        _valuesArray = [NSMutableArray arrayWithObjects:item.saleLeadNum, item.taskScheduleNum, item.approvalNum, item.fileNum, nil];
        if (item.isMarketOpen && ![item.isMarketOpen integerValue]) { // 开启会销模式，显示客户
            [_titlesArray insertObject:@"客户" atIndex:1];
            [_valuesArray insertObject:item.customerNum atIndex:1];
        }
    }
    else if (_type == SectionHeaderViewTypeLead) {
        _titlesArray = [NSMutableArray arrayWithObjects:@"日程任务", @"审批", nil];
        _valuesArray = [NSMutableArray arrayWithObjects:item.taskScheduleNum, item.approvalNum, nil];
    }
    else if (_type == SectionHeaderViewTypeCustomer) {
        _titlesArray = [NSMutableArray arrayWithObjects:@"销售机会", @"联系人", @"日程任务", @"审批", @"文档", nil];
        _valuesArray = [NSMutableArray arrayWithObjects:item.saleChanceNum, item.contactNum, item.taskScheduleNum, item.approvalNum, item.fileNum, nil];
    }
    else if (_type == SectionHeaderViewTypeContact) {
        _titlesArray = [NSMutableArray arrayWithObjects:@"销售机会", @"日程任务", @"审批", nil];
        _valuesArray = [NSMutableArray arrayWithObjects:item.saleChanceNum, item.taskScheduleNum, item.approvalNum, nil];
    }
    else if (_type == SectionHeaderViewTypeOpportunity) {
        _titlesArray = [NSMutableArray arrayWithObjects:@"联系人", @"日程任务", @"审批", @"产品", @"文档", nil];
        _valuesArray = [NSMutableArray arrayWithObjects:item.contactNum, item.taskScheduleNum, item.approvalNum, item.productNum, item.fileNum, nil];
    }
    
    [_collectionView reloadData];
}

#pragma mark - private method
- (CAShapeLayer*)createHorizontalLineWithColor:(UIColor*)color height:(CGFloat)height {
    CAShapeLayer *layer = [CAShapeLayer new];
    
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:CGPointMake(0, height - 0.5)];
    [path addLineToPoint:CGPointMake(kScreen_Width, height - 0.5)];
    
    layer.path = path.CGPath;
    layer.lineWidth = 0.5;
    layer.strokeColor = color.CGColor;
    
    CGPathRef bound = CGPathCreateCopyByStrokingPath(layer.path, nil, layer.lineWidth, kCGLineCapButt, kCGLineJoinMiter, layer.miterLimit);
    layer.bounds = CGPathGetBoundingBox(bound);
    CGPathRelease(bound);
    layer.position = CGPointMake(kScreen_Width / 2, height - 0.5 + 0.25);
    return layer;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _titlesArray.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SectionCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    [cell configWithNum:_valuesArray[indexPath.row] title:_titlesArray[indexPath.row]];
    return cell;
}

#pragma mark - UICollectionViewDelegate
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_titlesArray.count == 5) {
        return CGSizeMake(kScreen_Width / 4 - 10, CGRectGetHeight(self.bounds));
    }
    
    if (_titlesArray.count == 2) {
        return CGSizeMake(kScreen_Width / 2 - 10, CGRectGetHeight(self.bounds));
    }
    
    if (_titlesArray.count == 3) {
        return CGSizeMake(kScreen_Width / 3.0 - 10, CGRectGetHeight(self.bounds));
    }
    
    return CGSizeMake(kScreen_Width / 4 - 10, CGRectGetHeight(self.bounds));
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 5, 0, 0);
}

// 定义每个UICollectionViewItem 纵向的间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *titleStr = _titlesArray[indexPath.row];
    
    if ([titleStr isEqualToString:@"销售线索"]) {
        if (self.saleLeadBlock) {
            self.saleLeadBlock();
        }
    }
    
    if ([titleStr isEqualToString:@"销售机会"]) {
        if (self.saleOpportunityBlock) {
            self.saleOpportunityBlock();
        }
    }
    
    if ([titleStr isEqualToString:@"联系人"]) {
        if (self.contacterBlock) {
            self.contacterBlock();
        }
    }
    
    if ([titleStr isEqualToString:@"客户"]) {
        if (self.customerBlock) {
            self.customerBlock();
        }
    }
    
    if ([titleStr isEqualToString:@"审批"]) {
        if (self.approvalBlock) {
            self.approvalBlock();
        }
    }
    
    if ([titleStr isEqualToString:@"日程任务"]) {
        if (self.taskScheduleBlock) {
            self.taskScheduleBlock();
        }
    }
    
    if ([titleStr isEqualToString:@"产品"]) {
        if (self.productBlock) {
            self.productBlock();
        }
    }
    
    if ([titleStr isEqualToString:@"文档"]) {
        if (self.fileBlock) {
            self.fileBlock();
        }
    }
    
}

#pragma mark - setters and getters
- (UICollectionView*)collectionView {
    if (!_collectionView) {
        // 创建布局
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        //        SectionCollectionLayout *flowLayout = [[SectionCollectionLayout alloc] init];
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_collectionView setWidth:kScreen_Width];
        [_collectionView setHeight:CGRectGetHeight(self.bounds)];
        [_collectionView setBackgroundView:nil];
        [_collectionView setBackgroundColor:kView_BG_Color];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[SectionCollectionCell class] forCellWithReuseIdentifier:kCellIdentifier];
        
        // 添加底边边线
        [_collectionView.layer addSublayer:[self createHorizontalLineWithColor:[UIColor colorWithHexString:@"0xc8c7cc"] height:CGRectGetHeight(self.bounds)]];
    }
    return _collectionView;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
