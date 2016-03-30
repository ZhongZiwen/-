//
//  MeBusinessAchieveCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "MeBusinessAchieveCell.h"
#import "UIView+Common.h"

#import "CircleChartView.h"
#import "FunnelView.h"

#define kChartHeight 186

@interface MeBusinessAchieveCell ()

@property (nonatomic, strong) UILabel *m_titleLabel;        // 标题
@property (nonatomic, strong) CircleChartView *circleView;  // 仪表图
@property (nonatomic, strong) FunnelView *funnelView;       // 漏斗图
@property (nonatomic, strong) UILabel *m_sourceTitle0;
@property (nonatomic, strong) UILabel *m_sourceTitle1;
@property (nonatomic, strong) UILabel *m_source0;
@property (nonatomic, strong) UILabel *m_source1;
@end

@implementation MeBusinessAchieveCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        [self.contentView addSubview:self.m_titleLabel];
        [self.contentView addSubview:self.m_sourceTitle0];
        [self.contentView addSubview:self.m_source0];
        [self.contentView addSubview:self.m_sourceTitle1];
        [self.contentView addSubview:self.m_source1];
    }
    return self;
}

- (void)configWithSource:(NSDictionary *)sourceDict andChartType:(ChartType)chartType {
    if (chartType == ChartTypeCircle) {
        _m_titleLabel.text = @"销售目标完成情况";
        _m_sourceTitle0.text = @"销售目标";
        _m_sourceTitle1.text = @"完成总值";
        _m_source0.text = @"100元";
        _m_source1.text = @"2,010,000元";
        
        [self.contentView addSubview:self.circleView];
        
        return;
    }
    
    _m_titleLabel.text = @"销售漏斗";
    _m_sourceTitle0.text = @"漏斗总值";
    _m_sourceTitle1.text = @"预计完成";
    _m_source0.text = @"2,266,340,110个/17个";
    _m_source1.text = @"2,010,403,087元";
    
    [self.contentView addSubview:self.funnelView];
}

+ (CGFloat)cellHeight {
    return 130 + kChartHeight;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - setters and getters
- (UILabel*)m_titleLabel {
    if (!_m_titleLabel) {
        _m_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, kScreen_Width, 20)];
        _m_titleLabel.font = [UIFont systemFontOfSize:14];
        _m_titleLabel.textAlignment = NSTextAlignmentCenter;
        _m_titleLabel.textColor = [UIColor blackColor];
    }
    return _m_titleLabel;
}

- (CircleChartView*)circleView {
    if (!_circleView) {
        _circleView = [[CircleChartView alloc] initWithFrame:CGRectMake(0, 50, kScreen_Width, kChartHeight)];
        [_circleView setCenterX:kScreen_Width / 2];
        
    }
    return _circleView;
}

- (FunnelView*)funnelView {
    if (!_funnelView) {
        _funnelView = [[FunnelView alloc] initWithFrame:CGRectMake(0, 50, kScreen_Width, kChartHeight) withSlider:NO];
        [_funnelView setCenterX:kScreen_Width / 2];
    }
    return _funnelView;
}

- (UILabel*)m_sourceTitle0 {
    if (!_m_sourceTitle0) {
        _m_sourceTitle0 = [[UILabel alloc] initWithFrame:CGRectMake(44, 50 + kChartHeight + 10, 64, 20)];
        _m_sourceTitle0.font = [UIFont systemFontOfSize:14];
        _m_sourceTitle0.textColor = [UIColor lightGrayColor];
        _m_sourceTitle0.textAlignment = NSTextAlignmentLeft;
    }
    return _m_sourceTitle0;
}

- (UILabel*)m_source0 {
    if (!_m_source0) {
        _m_source0 = [[UILabel alloc] initWithFrame:CGRectMake(44, _m_sourceTitle0.frame.origin.y, kScreen_Width - 2 * 44, 20)];
        _m_source0.font = [UIFont systemFontOfSize:14];
        _m_source0.textColor = [UIColor blackColor];
        _m_source0.textAlignment = NSTextAlignmentRight;
    }
    return _m_source0;
}

- (UILabel*)m_sourceTitle1 {
    if (!_m_sourceTitle1) {
        _m_sourceTitle1 = [[UILabel alloc] initWithFrame:CGRectMake(_m_sourceTitle0.frame.origin.x, _m_sourceTitle0.frame.origin.y + CGRectGetHeight(_m_sourceTitle0.bounds) + 10, 64, 20)];
        _m_sourceTitle1.font = [UIFont systemFontOfSize:14];
        _m_sourceTitle1.textColor = [UIColor lightGrayColor];
        _m_sourceTitle1.textAlignment = NSTextAlignmentLeft;
    }
    return _m_sourceTitle1;
}

- (UILabel*)m_source1 {
    if (!_m_source1) {
        _m_source1 = [[UILabel alloc] initWithFrame:CGRectMake(44, _m_sourceTitle1.frame.origin.y, kScreen_Width - 2 * 44, 20)];
        _m_source1.font = [UIFont systemFontOfSize:14];
        _m_source1.textColor = [UIColor blackColor];
        _m_source1.textAlignment = NSTextAlignmentRight;
    }
    return _m_source1;
}

@end
