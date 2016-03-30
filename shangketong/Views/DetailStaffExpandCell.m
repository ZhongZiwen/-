//
//  DetailStaffExpandCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/11.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "DetailStaffExpandCell.h"
#import "DetailStaffModel.h"

@interface DetailStaffExpandCell ()

@property (strong, nonatomic) UIButton *changeBtn;
@property (strong, nonatomic) UIButton *deleteBtn;
@property (strong, nonatomic) UIImageView *changeView;
@property (strong, nonatomic) UIImageView *deleteView;
@property (strong, nonatomic) UILabel *changeName;
@property (strong, nonatomic) UILabel *deleteName;
@end

@implementation DetailStaffExpandCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.contentView.backgroundColor = [UIColor colorWithHexString:@"0xf0fff4"];
        [self.contentView addSubview:self.changeBtn];
        [self.contentView addSubview:self.deleteBtn];
    }
    return self;
}

- (void)configWithModel:(DetailStaffModel *)model {
    _changeView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", [model.staffLevel integerValue] == 3 ? @"set_owner" : @"cancel_owner"]];
    _changeName.text = [model.staffLevel integerValue] == 3 ? @"分配修改权限" : @"取消负责人";
}

#pragma mark - event response
- (void)changeBtnPress {
    if (self.changeBtnClickedBlock) {
        self.changeBtnClickedBlock();
    }
}

- (void)deleteBtnPress {
    if (self.deleteBtnClickedBlock) {
        self.deleteBtnClickedBlock();
    }
}

+ (CGFloat)cellHeight {
    return 54.0f;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - setters and getters
- (UIButton*)changeBtn {
    if (!_changeBtn) {
        _changeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_changeBtn setWidth:kScreen_Width / 2.0];
        [_changeBtn setHeight:[DetailStaffExpandCell cellHeight]];
        [_changeBtn addTarget:self action:@selector(changeBtnPress) forControlEvents:UIControlEventTouchUpInside];
        
        [_changeBtn addSubview:self.changeView];
        [_changeBtn addSubview:self.changeName];
    }
    return _changeBtn;
}

- (UIButton*)deleteBtn {
    if (!_deleteBtn) {
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteBtn setX:kScreen_Width / 2.0];
        [_deleteBtn setWidth:kScreen_Width / 2.0];
        [_deleteBtn setHeight:[DetailStaffExpandCell cellHeight]];
        [_deleteBtn addTarget:self action:@selector(deleteBtnPress) forControlEvents:UIControlEventTouchUpInside];
        
        [_deleteBtn addSubview:self.deleteView];
        [_deleteBtn addSubview:self.deleteName];
    }
    return _deleteBtn;
}

- (UIImageView*)changeView {
    if (!_changeView) {
        UIImage *image = [UIImage imageNamed:@"set_owner"];
        _changeView = [[UIImageView alloc] init];
        [_changeView setWidth:image.size.width];
        [_changeView setHeight:image.size.height];
        [_changeView setCenterX:CGRectGetWidth(_changeBtn.bounds) / 2.0];
        [_changeView setCenterY:CGRectGetMidY(_changeBtn.frame) - 5];
    }
    return _changeView;
}

- (UILabel*)changeName {
    if (!_changeName) {
        _changeName = [[UILabel alloc] init];
        [_changeName setY:CGRectGetMaxY(_changeView.frame)];
        [_changeName setWidth:CGRectGetWidth(_changeBtn.bounds)];
        [_changeName setHeight:15];
        _changeName.font = [UIFont systemFontOfSize:13];
        _changeName.textColor = LIGHT_BLUE_COLOR;
        _changeName.textAlignment = NSTextAlignmentCenter;
    }
    return _changeName;
}

- (UIImageView*)deleteView {
    if (!_deleteView) {
        UIImage *image = [UIImage imageNamed:@"today_operation_delete"];
        _deleteView = [[UIImageView alloc] initWithImage:image];
        [_deleteView setWidth:image.size.width];
        [_deleteView setHeight:image.size.height];
        [_deleteView setCenterX:CGRectGetWidth(_deleteBtn.bounds) / 2.0];
        [_deleteView setCenterY:CGRectGetMidY(_deleteBtn.frame) - 5];
    }
    return _deleteView;
}

- (UILabel*)deleteName {
    if (!_deleteName) {
        _deleteName = [[UILabel alloc] init];
        [_deleteName setY:CGRectGetMaxY(_deleteView.frame)];
        [_deleteName setWidth:CGRectGetWidth(_changeBtn.bounds)];
        [_deleteName setHeight:15];
        _deleteName.font = [UIFont systemFontOfSize:13];
        _deleteName.textColor = LIGHT_BLUE_COLOR;
        _deleteName.textAlignment = NSTextAlignmentCenter;
        _deleteName.text = @"删除";
    }
    return _deleteName;
}

@end
