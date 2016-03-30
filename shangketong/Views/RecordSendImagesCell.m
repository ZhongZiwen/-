//
//  RecordSendImagesCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/27.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "RecordSendImagesCell.h"
#import "RecordSendCollectionLayout.h"
#import "RecordSendCCell.h"
#import "PhotoAssetModel.h"

#define kCCellIdentifier @"RecordSendCCell"

@interface RecordSendImagesCell ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *imagesArray;
@end

@implementation RecordSendImagesCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // 创建布局
        RecordSendCollectionLayout *layout = [[RecordSendCollectionLayout alloc] init];
        
        if (!_collectionView) {
            _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, ([RecordSendCCell ccellSize].height + 10) * 3) collectionViewLayout:layout];
            _collectionView.backgroundColor = [UIColor whiteColor];
            _collectionView.dataSource = self;
            _collectionView.delegate = self;
            [_collectionView registerClass:[RecordSendCCell class] forCellWithReuseIdentifier:kCCellIdentifier];
            [self.contentView addSubview:_collectionView];
        }
        
    }
    return self;
}

- (void)configWithRecord:(NSArray *)array {
    _imagesArray = array;
    
    [_collectionView reloadData];
}

+ (CGFloat)cellHeightWithObj:(id)obj {
    
    return ([RecordSendCCell ccellSize].height + 10) * 3;
}

#pragma mark - UICollectionView_M
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_imagesArray.count && _imagesArray.count < 9) {
        return _imagesArray.count + 1;
    }
    return _imagesArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [RecordSendCCell ccellSize];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RecordSendCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCCellIdentifier forIndexPath:indexPath];
    if (indexPath.row < _imagesArray.count) {
        PhotoAssetModel *item = _imagesArray[indexPath.row];
        cell.photoAsset = item;
    }
    else {
        cell.photoAsset = nil;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < _imagesArray.count) {
        if (self.tapImageBlock) {
            self.tapImageBlock(indexPath.row);
        }
        return;
    }
    
    if (self.addImageBlock) {
        self.addImageBlock();
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
