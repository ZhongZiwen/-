//
//  DetailInfoCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/8.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "DetailInfoCell.h"
#import "ColumnModel.h"
#import "ColumnSelectModel.h"
#import "User.h"

@interface DetailInfoCell ()

@property (strong, nonatomic) UILabel *m_title;
@property (strong, nonatomic) UILabel *m_detail;
@property (strong, nonatomic) UIImageView *m_header;
@end

@implementation DetailInfoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.contentView addSubview:self.m_title];
        [self.contentView addSubview:self.m_detail];
        [self.contentView addSubview:self.m_header];
    }
    return self;
}

- (void)configWithModel:(ColumnModel *)model {
    _m_title.text = model.name;
    
    // 单选
    if ([model.columnType isEqualToNumber:@3]) {
        _m_header.hidden = YES;
        _m_detail.hidden = NO;
        
        NSString *result = model.stringResult;
        NSString *string;

        if (!result) {
            string = @"未选择";
        }
        else {
            for (ColumnSelectModel *selectModel in model.selectArray) {
                if ([result isEqualToString:selectModel.id]) {
                    string = selectModel.value;
                    break;
                }
            }
        }

        CGFloat height = [string getHeightWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(CGRectGetWidth(self.m_detail.bounds), CGFLOAT_MAX)];
        [_m_detail setHeight:MAX(height, 20)];
        _m_detail.text = string;
        return;
    }
    
    // 多选
    if ([model.columnType isEqualToNumber:@4]) {
        _m_header.hidden = YES;
        _m_detail.hidden = NO;
        NSString *string;
        for (int i = 0; i < model.arrayResult.count; i ++) {
            NSString *tempStr = model.arrayResult[i];
            for (ColumnSelectModel *selectItem in model.selectArray) {
                if ([selectItem.id isEqualToString:tempStr]) {
                    if (i) {
                        string = [NSString stringWithFormat:@"%@,%@", string, selectItem.value];
                    }
                    else {
                        string = selectItem.value;
                    }
                    break;
                }
            }
        }
        if (!string) {
            string = @"未选择";
        }
        
        CGFloat height = [string getHeightWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(CGRectGetWidth(self.m_detail.bounds), CGFLOAT_MAX)];
        [_m_detail setHeight:MAX(height, 20)];
        _m_detail.text = string;
        return;
    }
    
    // 日期类型
    if ([model.columnType isEqualToNumber:@7]) {
        _m_header.hidden = YES;
        _m_detail.hidden = NO;
        if (!model.dateResult) {
            _m_detail.text = @"未填写";
        }
        else {
            if (![model.fullDate integerValue]) {
                _m_detail.text = [model.dateResult stringTimestamp];
            }
            else {
                _m_detail.text = [model.dateResult stringYearMonthDayForLine];
            }
        }
        return;
    }
    
    // 对象类型
    if ([model.columnType isEqualToNumber:@10]) {
        User *user = model.objectResult;
        if ([model.type isEqualToNumber:@203]) {  // 客户
            _m_header.hidden = YES;
            _m_detail.hidden = NO;
            _m_detail.text = [NSString stringWithFormat:@"%@", user.name];
        }
        else {
            _m_header.hidden = NO;
            _m_detail.hidden = YES;
            [_m_header sd_setImageWithURL:[NSURL URLWithString:user.icon] placeholderImage:[UIImage imageNamed:@"user_icon_default"]];
        }
        return;
    }
    
    // 所属部门
    if ([model.columnType isEqualToNumber:@100]) {
        _m_header.hidden = YES;
        _m_detail.hidden = NO;
        
        for (ColumnSelectModel *selectModel in model.selectArray) {
            if ([model.stringResult isEqualToString:selectModel.id]) {
                
                CGFloat height = [selectModel.value getHeightWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(CGRectGetWidth(self.m_detail.bounds), CGFLOAT_MAX)];
                [_m_detail setHeight:MAX(height, 20)];
                _m_detail.text = selectModel.value;
            }
        }
        return;
    }
    
    _m_header.hidden = YES;
    _m_detail.hidden = NO;
    
    NSString *string = [NSString stringWithFormat:@"%@", model.stringResult ? model.stringResult : @"未填写"];
    CGFloat height = [string getHeightWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(CGRectGetWidth(self.m_detail.bounds), CGFLOAT_MAX)];
    [_m_detail setHeight:MAX(height, 20)];
    _m_detail.text = string;
}

- (void)headerViewTap {
    if (self.headerViewTapBlock) {
        self.headerViewTapBlock();
    }
}

+ (CGFloat)cellHeightWithModel:(ColumnModel *)model {
    
    CGFloat mHeight = 0;
    if ([model.columnType isEqualToNumber:@3]) {
        NSString *result = model.stringResult;
        NSString *string;
        
        if (!result) {
            string = @"未选择";
        }
        else {
            for (ColumnSelectModel *selectModel in model.selectArray) {
                if ([result isEqualToString:selectModel.id]) {
                    string = selectModel.value;
                    break;
                }
            }
        }
        
        CGFloat height = [string getHeightWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(kScreen_Width - 30, CGFLOAT_MAX)];
        mHeight = MAX(height, 20);
    }
    else if ([model.columnType isEqualToNumber:@4]) {
        NSString *string;
        for (int i = 0; i < model.arrayResult.count; i ++) {
            NSString *tempStr = model.arrayResult[i];
            for (ColumnSelectModel *selectItem in model.selectArray) {
                if ([selectItem.id isEqualToString:tempStr]) {
                    if (i) {
                        string = [NSString stringWithFormat:@"%@,%@", string, selectItem.value];
                    }
                    else {
                        string = selectItem.value;
                    }
                    break;
                }
            }
        }
        if (!string) {
            string = @"未选择";
        }
        
        CGFloat height = [string getHeightWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(kScreen_Width - 30, CGFLOAT_MAX)];
        mHeight = MAX(height, 20);
    }
    else if ([model.columnType isEqualToNumber:@7]) {
        mHeight = 20;
    }
    else if ([model.columnType isEqualToNumber:@10]) {
        mHeight = 30;
    }
    else if ([model.columnType isEqualToNumber:@100]) {
        for (ColumnSelectModel *selectModel in model.selectArray) {
            if ([model.stringResult isEqualToString:selectModel.id]) {
                
                CGFloat height = [selectModel.value getHeightWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(kScreen_Width - 30, CGFLOAT_MAX)];
                mHeight = MAX(height, 20);
            }
        }
    }
    else {
        NSString *string = [NSString stringWithFormat:@"%@", model.stringResult ? model.stringResult : @"未填写"];
        CGFloat height = [string getHeightWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(kScreen_Width - 30, CGFLOAT_MAX)];
        mHeight = MAX(height, 20);
    }
    
    return 44 + mHeight;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - setters and getters
- (UILabel*)m_title {
    if (!_m_title) {
        _m_title = [[UILabel alloc] init];
        [_m_title setX:15];
        [_m_title setY:10];
        [_m_title setWidth:kScreen_Width - 15 - 10];
        [_m_title setHeight:24];
        _m_title.font = [UIFont systemFontOfSize:16];
        _m_title.textAlignment = NSTextAlignmentLeft;
        _m_title.textColor = kNavigationTintColor;
    }
    return _m_title;
}

- (UILabel*)m_detail {
    if (!_m_detail) {
        _m_detail = [[UILabel alloc] init];
        [_m_detail setX:CGRectGetMinX(_m_title.frame)];
        [_m_detail setY:CGRectGetMaxY(_m_title.frame)];
        [_m_detail setWidth:CGRectGetWidth(_m_title.bounds)];
        [_m_detail setHeight:20];
        _m_detail.font = [UIFont systemFontOfSize:14];
        _m_detail.textAlignment = NSTextAlignmentLeft;
        _m_detail.textColor = [UIColor blackColor];
        _m_detail.numberOfLines = 0;
        _m_detail.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _m_detail;
}

- (UIImageView*)m_header {
    if (!_m_header) {
        _m_header = [[UIImageView alloc] init];
        [_m_header setX:15];
        [_m_header setY:CGRectGetMaxY(_m_title.frame)];
        [_m_header setWidth:30];
        [_m_header setHeight:30];
        _m_header.contentMode = UIViewContentModeScaleAspectFill;
        _m_header.clipsToBounds = YES;
        _m_header.userInteractionEnabled = YES;
        [_m_header doCircleFrame];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerViewTap)];
        [_m_header addGestureRecognizer:tap];
    }
    return _m_header;
}
@end
