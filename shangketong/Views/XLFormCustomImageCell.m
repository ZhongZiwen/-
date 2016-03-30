//
//  XLFormCustomImageCell.m
//  shangketong
//
//  Created by sungoin-zbs on 16/3/4.
//  Copyright © 2016年 sungoin. All rights reserved.
//

#import "XLFormCustomImageCell.h"
#import "PhotoAssetLibraryViewController.h"
#import "PhotoAssetModel.h"
#import "PhotoBrowserViewController.h"

NSString * const XLFormRowDescriptorTypeCustomeImage = @"XLFormRowDescriptorTypeCustomeImage";

@interface XLFormCustomImageCell ()<PhotoBrowserDelegate>

@property (strong, nonatomic) UIImageView *mImageView;
@end

@implementation XLFormCustomImageCell

+ (void)load {
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:[XLFormCustomImageCell class] forKey:XLFormRowDescriptorTypeCustomeImage];
}

#pragma mark - XLFormDescriptorCell
- (void)configure {
    [super configure];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.contentView addSubview:self.mImageView];
}

- (void)update {
    [super update];
    
    if (!self.rowDescriptor.value) {
        _mImageView.image = [UIImage imageNamed:@"add-normal"];
        return;
    }
    
    // 编辑审批，value为附件图片的url
    if ([self.rowDescriptor.value isKindOfClass:[NSString class]]) {
        [_mImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", self.rowDescriptor.value]] placeholderImage:[UIImage imageNamed:PLACEHOLDER_REVIEW_IMG]];
    }else{
        PhotoAssetModel *item = self.rowDescriptor.value;
        self.mImageView.image = [UIImage imageWithCGImage:item.asset.thumbnail];
    }
}


- (void)formDescriptorCellDidSelectedWithFormController:(XLFormViewController *)controller {
    
    if (self.rowDescriptor.action.formBlock){
        self.rowDescriptor.action.formBlock(self.rowDescriptor);
    }
    [self.formViewController.tableView selectRowAtIndexPath:nil animated:YES scrollPosition:UITableViewScrollPositionNone];
}

+ (CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor {
    return 84.0f;
}

#pragma mark - event response
- (void)tapGesture:(UITapGestureRecognizer *)sender {
    if (self.rowDescriptor.value && [self.rowDescriptor.value isKindOfClass:[PhotoAssetModel class]]) {
        PhotoBrowserViewController *photoBrowserController = [[PhotoBrowserViewController alloc] initWithDelegate:self];
        photoBrowserController.photoType = PhotoBrowserTypeDelete;
        photoBrowserController.currentPageIndex = 0;
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:photoBrowserController];
        [self.formViewController presentViewController:nav animated:YES completion:nil];
        return;
    }
    
    @weakify(self);
    PhotoAssetLibraryViewController *assetLibraryController = [[PhotoAssetLibraryViewController alloc] init];
    assetLibraryController.maxCount = 1;
    assetLibraryController.confirmBtnClickedBlock = ^(NSArray *array) {
        @strongify(self);
        PhotoAssetModel *item = array.firstObject;
        self.mImageView.image = [UIImage imageWithCGImage:item.asset.thumbnail];
        self.rowDescriptor.value = item;
    };
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:assetLibraryController];
    [self.formViewController presentViewController:nav animated:YES completion:nil];
}

#pragma mark - PhotoBrowserDelegate
- (NSUInteger)numberOfSelectedPhotosInPhotoBrowser:(PhotoBrowserViewController *)photoBrowser {
    if (self.rowDescriptor.value) {
        return 1;
    }
    return 0;
}

- (PhotoAssetModel *)photoBrowser:(PhotoBrowserViewController *)photoBrowser selectedPhotoAtIndex:(NSUInteger)index {
    PhotoAssetModel *item = self.rowDescriptor.value;
    return item;
}

- (void)photoBrowser:(PhotoBrowserViewController *)photoBrowser cancelSelectedPhoto:(PhotoAssetModel *)photoModel {
    self.rowDescriptor.value = nil;
    self.mImageView.image = [UIImage imageNamed:@"add-normal"];
}

#pragma mark - setters and getters
- (UIImageView *)mImageView {
    if (!_mImageView) {
        _mImageView = [[UIImageView alloc] init];
        [_mImageView setX:15];
        [_mImageView setY:8];
        [_mImageView setWidth:84 - 2 * 8];
        [_mImageView setHeight:84 - 2 * 8];
        _mImageView.userInteractionEnabled = YES;
        _mImageView.contentMode = UIViewContentModeScaleAspectFill;
        _mImageView.clipsToBounds = YES;
        
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
//        [_mImageView addGestureRecognizer:tap];
    }
    return _mImageView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
