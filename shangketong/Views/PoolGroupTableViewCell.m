//
//  PoolGroupTableViewCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/9/28.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "PoolGroupTableViewCell.h"
#import "SaleLeadPool.h"
#import "CustomerPool.h"

@interface PoolGroupTableViewCell ()

@property (strong, nonatomic) UILabel *name;
@property (strong, nonatomic) UILabel *companyName;
@property (strong, nonatomic) UILabel *detail;
@end

@implementation PoolGroupTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.name];
        [self.contentView addSubview:self.companyName];
        [self.contentView addSubview:self.detail];
        [self.contentView addSubview:self.receiveBtn];
    }
    return self;
}

- (void)configWithObj:(id)obj {
    
    if ([obj isKindOfClass:[SaleLeadPool class]]) {
        
        SaleLeadPool *saleLead = obj;
        
        _name.text = saleLead.name;
        _companyName.text = saleLead.companyName;
        if (saleLead.reason) {
            _detail.text = [NSString stringWithFormat:@"%@创建 退回%@次:%@", [saleLead.createTime stringMonthDay], saleLead.backCount, saleLead.reason];
        }else {
            _detail.text = [NSString stringWithFormat:@"%@创建 退回%@次", [saleLead.createTime stringMonthDay], saleLead.backCount];
        }
        
        [_receiveBtn setCenterY:42.0f];
        if ([saleLead.canGet integerValue]) {
            _receiveBtn.hidden = YES;
        }else {
            _receiveBtn.hidden = NO;
            if (saleLead.isGet) {
                _receiveBtn.enabled = NO;
                [_receiveBtn setTitle:@"已领取" forState:UIControlStateNormal];
            }else {
                _receiveBtn.enabled = YES;
                [_receiveBtn setTitle:@"领取" forState:UIControlStateNormal];
            }
        }
        
        return;
    }
    
    CustomerPool *customer = obj;
    
    _companyName.hidden = YES;
    [_detail setY:CGRectGetMaxY(_name.frame)];
    
    _name.text = customer.name;
    if (customer.reason) {
        _detail.text = [NSString stringWithFormat:@"%@创建 退回%@次:%@", [customer.createTime stringMonthDay], customer.backCount, customer.reason];
    }else {
        _detail.text = [NSString stringWithFormat:@"%@创建 退回%@次", [customer.createTime stringMonthDay], customer.backCount];
    }
    
    [_receiveBtn setCenterY:32.0f];
    if ([customer.canGet integerValue]) {
        _receiveBtn.hidden = YES;
    }else {
        _receiveBtn.hidden = NO;
        if (customer.isGet) {
            _receiveBtn.enabled = NO;
            [_receiveBtn setTitle:@"已领取" forState:UIControlStateNormal];
        }else {
            _receiveBtn.enabled = YES;
            [_receiveBtn setTitle:@"领取" forState:UIControlStateNormal];
        }
    }
}

- (void)receiveButtonPress:(UIButton*)sender {
    if (self.receiveBtnClickedBlock) {
        self.receiveBtnClickedBlock(sender.tag);
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#pragma mark - setters and getters
- (UILabel*)name {
    if (!_name) {
        _name = [[UILabel alloc] init];
        [_name setX:15];
        [_name setY:10];
        [_name setWidth:kScreen_Width - 30];
        [_name setHeight:24];
        _name.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
        _name.textAlignment = NSTextAlignmentLeft;
    }
    return _name;
}

- (UILabel*)companyName {
    if (!_companyName) {
        _companyName = [[UILabel alloc] init];
        [_companyName setX:CGRectGetMinX(_name.frame)];
        [_companyName setY:CGRectGetMaxY(_name.frame)];
        [_companyName setWidth:CGRectGetWidth(_name.bounds)];
        [_companyName setHeight:20];
        _companyName.font = [UIFont systemFontOfSize:14];
        _companyName.textColor = [UIColor iOS7darkGrayColor];
        _companyName.textAlignment = NSTextAlignmentLeft;
    }
    return _companyName;
}

- (UILabel*)detail {
    if (!_detail) {
        _detail = [[UILabel alloc] init];
        [_detail setX:CGRectGetMinX(_name.frame)];
        [_detail setY:CGRectGetMaxY(_companyName.frame)];
        [_detail setWidth:CGRectGetWidth(_name.bounds)];
        [_detail setHeight:20];
        _detail.font = [UIFont systemFontOfSize:14];
        _detail.textColor = [UIColor iOS7darkGrayColor];
        _detail.textAlignment = NSTextAlignmentLeft;
    }
    return _detail;
}

- (UIButton*)receiveBtn {
    if (!_receiveBtn) {
        _receiveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_receiveBtn setX:kScreen_Width - 44 - 10];
        [_receiveBtn setWidth:44];
        [_receiveBtn setHeight:25];
        _receiveBtn.layer.cornerRadius = 4;
        _receiveBtn.layer.borderWidth = 0.5;
        _receiveBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        _receiveBtn.layer.borderColor = [UIColor iOS7lightBlueColor].CGColor;
        [_receiveBtn setTitleColor:[UIColor iOS7lightBlueColor] forState:UIControlStateNormal];
        [_receiveBtn addTarget:self action:@selector(receiveButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _receiveBtn;
}

@end
