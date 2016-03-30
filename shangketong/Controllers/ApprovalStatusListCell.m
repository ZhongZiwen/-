//
//  ApprovalStatusListCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/8/6.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ApprovalStatusListCell.h"
#import "NSString+Common.h"
#import "UIView+Common.h"
#import <UIImageView+WebCache.h>

@interface ApprovalStatusListCell ()
{
    CGFloat height;
}
@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) UIView *signal;
@property (nonatomic, strong) UILabel *time;
@property (nonatomic, strong) UIImageView *headImage;
@property (nonatomic, strong) UILabel *content;
@property (nonatomic, strong) UILabel *adviceLabel;
@property (nonatomic, strong) UIImageView *adviceImageView;
@end

@implementation ApprovalStatusListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.line];
        [self.contentView addSubview:self.signal];
        [self.contentView addSubview:self.time];
        [self.contentView addSubview:self.headImage];
        [self.contentView addSubview:self.content];
        [self.contentView addSubview:self.adviceImageView];
        [self.contentView addSubview:self.adviceLabel];
    }
    return self;
}

- (void)configWithDictionary:(NSDictionary *)dict {
    
//    NSArray *colorArray = @[@"0x62c42d", @"0xffa228", @"0xff0f0f"];
    
//    UIColor *signalColor = [UIColor colorWithHexString:colorArray[[dict[@"signal"] integerValue] - 1]];
    
    
    UIColor *signalColor = SKT_OA_APPROVAL_STATUS_DEFAULT;
//    CREATE(1, "提交了此申请"),
//    AGREE(2, "同意该审批"),
//    REJECT(3, "拒绝该审批"),
//    RECALL(4, "撤回该审批"),
//    RECREATE(5, "重新提交了审批"),
//    PENDING(6, "等待审批");
    NSInteger colorType = [dict[@"signal"] integerValue];
    switch (colorType) {
        case 1:
            
            break;
        case 2:
            signalColor = SKT_OA_APPROVAL_STATUS_GREEN;
            break;
        case 3:
            signalColor = SKT_OA_APPROVAL_STATUS_RED;
            break;
        case 4:
            signalColor = SKT_OA_APPROVAL_STATUS_YELLOW;
            break;
        case 5:
            
            break;
        case 6:
            
            break;
            
        default:
            break;
    }
    _signal.backgroundColor = signalColor;
    _time.textColor = signalColor;
    _content.textColor = signalColor;
    
//    if (dict[@"time"] != [NSNull null]) {
//        _time.text = [NSString transDateWithTimeInterval:dict[@"time"] andCustomFormate:@"MM-dd HH:mm"];
//    }else {
//        _time.text = [NSString transDateWithTimeInterval:@"" andCustomFormate:@"MM-dd HH:mm"];
//    }
    if ([CommonFuntion checkNullForValue:dict[@"time"]]) {
       _time.text = [[CommonFuntion getStringForTime:[dict[@"time"] longLongValue]] substringWithRange:NSMakeRange(5, 11)];
    }
    if (dict[@"user"][@"icon"] != [NSNull null]) {
        [_headImage sd_setImageWithURL:[NSURL URLWithString:dict[@"user"][@"icon"]] placeholderImage:[UIImage imageNamed:@"user_icon_default"]];
    }else {
        _headImage.image = [UIImage imageNamed:@"user_icon_default"];
    }
    
    _content.textColor = signalColor;
    _content.text = [NSString stringWithFormat:@"%@ %@", dict[@"user"][@"name"], dict[@"content"]];
    if ([CommonFuntion checkNullForValue:[dict safeObjectForKey:@"advice"]]) {
        height = [[dict safeObjectForKey:@"advice"] getHeightWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(CGRectGetWidth(_adviceLabel.bounds), MAXFLOAT)] + 20;
        [_adviceLabel setHeight:height];
        [_adviceImageView setHeight:height];
        [_line setHeight:CGRectGetHeight(_line.bounds) + height];
        _adviceLabel.text = [dict safeObjectForKey:@"advice"];
    }
}

+ (CGFloat)cellHeightWithDictionary:(NSDictionary*)dict {
    if ([CommonFuntion checkNullForValue:[dict safeObjectForKey:@"advice"]]) {
       CGFloat h = [[dict safeObjectForKey:@"advice"] getHeightWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(kScreen_Width - 100, MAXFLOAT)] + 20;
        return 70.f + h;
    }
    return 70.f;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - setters and getters
- (UIView*)line {
    if (!_line) {
        _line = [[UIView alloc] initWithFrame:CGRectMake(20, 0, 0.5, 70)];
        _line.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0f];
    }
    return _line;
}

- (UIView*)signal {
    if (!_signal) {
        _signal = [[UIView alloc] initWithFrame:CGRectMake(0, 15, 6, 6)];
        [_signal setCenterX:20 + 0.25];
        _signal.layer.cornerRadius = 3;
        _signal.clipsToBounds = YES;
    }
    return _signal;
}

- (UILabel*)time {
    if (!_time) {
        _time = [[UILabel alloc] initWithFrame:CGRectMake(35, 0, kScreen_Width - 35, 20)];
        [_time setCenterY:_signal.center.y];
        _time.font = [UIFont systemFontOfSize:12];
        _time.textAlignment = NSTextAlignmentLeft;
    }
    return _time;
}

- (UIImageView*)headImage {
    if (!_headImage) {
        _headImage = [[UIImageView alloc] initWithFrame:CGRectMake(35, 30, 30, 30)];
        
    }
    return _headImage;
}

- (UILabel*)content {
    if (!_content) {
        _content = [[UILabel alloc] initWithFrame:CGRectMake(75, 0, kScreen_Width - 75, 20)];
        [_content setCenterY:_headImage.center.y];
        _content.font = [UIFont systemFontOfSize:14];
        _content.textAlignment = NSTextAlignmentLeft;
    }
    return _content;
}
- (UILabel *)adviceLabel {
    if (!_adviceLabel) {
        _adviceLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 65, kScreen_Width - 70, 0)];
        _adviceLabel.font = [UIFont systemFontOfSize:14];
        _adviceLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _adviceLabel.textColor = [UIColor lightGrayColor];
        _adviceLabel.numberOfLines = 0;
    }
    return _adviceLabel;
}
- (UIImageView *)adviceImageView {
    if (!_adviceImageView) {
        _adviceImageView = [[UIImageView alloc] init];
        _adviceImageView.frame = CGRectMake(45, 65, kScreen_Width - 65, 0);
//        _adviceImageView.backgroundColor = [UIColor colorWithHexString:@"ffdad4"];
        _adviceImageView.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
        _adviceImageView.layer.borderWidth = 1.0f;
//        _adviceImageView.layer.borderColor = [UIColor colorWithHexString:@"ff9491"].CGColor;
        _adviceImageView.layer.borderColor = COMMEN_VIEW_BACKGROUNDCOLOR.CGColor;
    }
    return _adviceImageView;
}
@end
