//
//  XLFImageTextCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/8/19.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "XLFImageTextCell.h"
#import "UIView+Common.h"

NSString * const XLFormRowDescriptorTypeImageText = @"XLFormRowDescriptorTypeImageText";

@interface XLFImageTextCell ()

@property (nonatomic, strong) UIImageView *m_imageView;
@property (nonatomic, strong) UILabel *m_titleLabel;
@end

@implementation XLFImageTextCell

+ (void)load {
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:[XLFImageTextCell class] forKey:XLFormRowDescriptorTypeImageText];
}

- (void)configure {
    [super configure];
    
    [self.contentView addSubview:self.m_imageView];
    [self.contentView addSubview:self.m_titleLabel];
}

- (void)update {
    
    [super update];
    
    NSDictionary *sourceDict = (NSDictionary*)self.rowDescriptor.value;
    
    _m_titleLabel.text = [sourceDict safeObjectForKey:@"name"];
    
}

- (void)formDescriptorCellDidSelectedWithFormController:(XLFormViewController *)controller {
    
    if (self.rowDescriptor.action.formBlock){
        self.rowDescriptor.action.formBlock(self.rowDescriptor);
    }
    [self.formViewController.tableView selectRowAtIndexPath:nil animated:YES scrollPosition:UITableViewScrollPositionNone];
}

+ (CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor {
    return 50.f;
}

#pragma mark - setters and getters
- (UIImageView*)m_imageView {
    if (!_m_imageView) {
        UIImage *image = [UIImage imageNamed:@"file_document_32"];
        _m_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 0, image.size.width, image.size.height)];
        _m_imageView.image = image;
        [_m_imageView setCenterY:25.f];
    }
    return _m_imageView;
}

- (UILabel*)m_titleLabel {
    if (!_m_titleLabel) {
        _m_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15 + CGRectGetWidth(_m_imageView.bounds) + 10, 0, kScreen_Width - 15 - CGRectGetWidth(_m_imageView.bounds) - 10 - 20, 50.f)];
        _m_titleLabel.font = [UIFont systemFontOfSize:14];
        _m_titleLabel.textColor = [UIColor blackColor];
        _m_titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _m_titleLabel;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
