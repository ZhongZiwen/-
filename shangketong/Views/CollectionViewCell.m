//
//  CollectionViewCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/9/11.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "CollectionViewCell.h"
#import <UIImageView+WebCache.h>
#import "AddressBook.h"
#import "FilterValue.h"

#define kSpaceWidth 10
#define kWidth (kScreen_Width - 6 * kSpaceWidth)/5.0

@interface CollectionViewCell ()

@property (weak, nonatomic) UIImageView *headerView;
@property (weak, nonatomic) UILabel *name;
@property (weak, nonatomic) UIImageView *deleteView;
@end

@implementation CollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = kView_BG_Color;
        
        // 头像
        UIImageView *iView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kWidth, kWidth)];
        iView.contentMode = UIViewContentModeScaleAspectFill;
        iView.clipsToBounds = YES;
        [self.contentView addSubview:iView];
        _headerView = iView;
        
        // 用户名
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, kWidth, kWidth, 20)];
        label.font = [UIFont systemFontOfSize:12];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        [self.contentView addSubview:label];
        _name = label;
        
        // 删除
        UIImageView *deleteView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"deletePersonBtn_default"]];
        deleteView.userInteractionEnabled = YES;
        [deleteView setCenterX:5];
        [deleteView setCenterY:5];
        [deleteView setWidth:15];
        [deleteView setHeight:15];
        [self.contentView addSubview:deleteView];
        _deleteView = deleteView;
    }
    return self;
}

- (void)configWithAddressBook:(AddressBook *)item isDelete:(BOOL)isDelete {
    if (isDelete) {
        _deleteView.hidden = NO;
    }else {
        _deleteView.hidden = YES;
    }
    
    [_headerView sd_setImageWithURL:[NSURL URLWithString:item.icon] placeholderImage:[UIImage imageNamed:@"user_icon_default"]];
    _name.hidden = NO;
    _name.text = item.name;
}

- (void)configWithFilterValue:(FilterValue *)item isDelete:(BOOL)isDelete {
    if (isDelete) {
        _deleteView.hidden = NO;
    }else {
        _deleteView.hidden = YES;
    }
    
    [_headerView sd_setImageWithURL:[NSURL URLWithString:item.icon] placeholderImage:[UIImage imageNamed:@"user_icon_default"]];
    _name.hidden = NO;
    _name.text = item.name;
}

- (void)configWithImageStr:(NSString *)imageStr {
    _name.hidden = YES;
    _deleteView.hidden = YES;
    _headerView.image = [UIImage imageNamed:imageStr];
}
@end
