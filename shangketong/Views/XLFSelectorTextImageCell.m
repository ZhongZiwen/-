//
//  XLFSelectorTextImageCell.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/8.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "XLFSelectorTextImageCell.h"
#import <UIImageView+WebCache.h>

NSString * const XLFormRowDescriptorTypeSelectorTextImage = @"XLFormRowDescriptorTypeSelectorTextImage";

@interface XLFSelectorTextImageCell ()

@property (nonatomic, strong) UILabel *m_textLabel;
@property (nonatomic, strong) UIImageView *m_imageView;
@end

@implementation XLFSelectorTextImageCell

+ (void)load {
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:[XLFSelectorTextImageCell class] forKey:XLFormRowDescriptorTypeSelectorTextImage];
}

- (void)configure {
    [super configure];
    
    [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [self.contentView addSubview:self.m_textLabel];
    [self.contentView addSubview:self.m_imageView];
}

- (void)update {
    [super update];
    
    NSDictionary *dict = self.rowDescriptor.value;
    
    _m_textLabel.text = [dict objectForKey:@"text"];
    
    if ([[dict objectForKey:@"isWebImage"] boolValue]) {
        [_m_imageView sd_setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"user_icon_default"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            NSMutableDictionary *mutDict = [self.rowDescriptor.value mutableCopy];
            [mutDict setObject:image forKey:@"image"];
            [mutDict setObject:@"0" forKey:@"isWebImage"];
            self.rowDescriptor.value = mutDict;
        }];
    }else {
        _m_imageView.image = [dict objectForKey:@"image"];
    }
}

- (void)formDescriptorCellDidSelectedWithFormController:(XLFormViewController *)controller {
    
    if (self.rowDescriptor.action.formBlock){
        self.rowDescriptor.action.formBlock(self.rowDescriptor);
    }
    
    [self.formViewController.tableView selectRowAtIndexPath:nil animated:YES scrollPosition:UITableViewScrollPositionNone];
}

+(CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor {
    return 44;
}

#pragma mark - setters and getters
- (UILabel*)m_textLabel {
    if (!_m_textLabel) {
        _m_textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 44)];
        _m_textLabel.font = [UIFont systemFontOfSize:15];
        _m_textLabel.textColor = [UIColor blackColor];
        _m_textLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _m_textLabel;
}

- (UIImageView*)m_imageView {
    if (!_m_imageView) {
        _m_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreen_Width - 30 - 40, 2, 40, 40)];
        _m_imageView.contentMode = UIViewContentModeScaleAspectFill;
        _m_imageView.clipsToBounds = YES;
    }
    return _m_imageView;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
