//
//  MeBusinessHeadCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/8.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "MeBusinessHeadCell.h"
#import "UIView+Common.h"
#import "NSString+Common.h"

#import "CustomActionSheet.h"
#import "CustomPopView.h"

@interface MeBusinessHeadCell ()

@property (nonatomic, strong) UISegmentedControl *segment;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIButton *periodButton;   // 时间选择
@property (nonatomic, strong) UIButton *conditionButton;    // 条件筛选

/** 对button中title和image重新布局*/
- (void)configForButton:(UIButton*)button withTitleString:(NSString*)titleStr withImageString:(NSString*)imageStr withSpace:(CGFloat)space;
@end

@implementation MeBusinessHeadCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.segment];
        [self.contentView addSubview:self.lineView];
        [self.contentView addSubview:self.periodButton];
        [self.contentView addSubview:self.conditionButton];
    }
    return self;
}

+ (CGFloat)cellHeight {
    return 84.0f;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - private method
- (void)configForButton:(UIButton *)button withTitleString:(NSString *)titleStr withImageString:(NSString *)imageStr withSpace:(CGFloat)space {
    UIImage *image = [UIImage imageNamed:imageStr];
    CGFloat titleWidth = [titleStr getWidthWithFont:button.titleLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, 20)];
    
    button.titleEdgeInsets = UIEdgeInsetsMake(0, -image.size.width - space, 0, image.size.width + space);
    button.imageEdgeInsets = UIEdgeInsetsMake(0, titleWidth + space, 0, -titleWidth - space);
    
    [button setTitle:titleStr forState:UIControlStateNormal];
    [button setImage:image forState:UIControlStateNormal];
}

#pragma mark - event response
- (void)segmentChange:(UISegmentedControl*)segmentControl {

}

- (void)periodButtonPress:(UIButton*)sender {
    

    NSArray *titlesArray;
    if (_segment.selectedSegmentIndex == 0) {
        titlesArray = @[@"本月", @"本季度", @"本年"];
    }else {
        titlesArray = @[@"本日", @"昨日", @"本周", @"上周", @"本月", @"上月", @"自定义"];
    }
    __weak __block typeof(self) weak_self = self;
    CustomActionSheet *actionSheet = [[CustomActionSheet alloc] init];
    actionSheet.title = @"选择时间";
    actionSheet.sourceArray = titlesArray;
    actionSheet.actionType = ActionSheetTypeFromOther;
    actionSheet.selectedBlock = ^(id obj, ActionSheetTypeFrom fromType) {
        NSNumber *index = obj;
        [weak_self configForButton:weak_self.periodButton withTitleString:titlesArray[[index integerValue]] withImageString:@"user_gray_selectDateRange" withSpace:5.0];
    };
    [actionSheet show];
}

- (void)conditionButtonPress:(UIButton*)sender {
    
    if (self.conditionBlock) {
        self.conditionBlock(sender);
    }
}

#pragma mark - setters and getters
- (UISegmentedControl*)segment {
    if (!_segment) {
        _segment = [[UISegmentedControl alloc] initWithItems:@[@"业绩", @"行为"]];
        _segment.frame = CGRectMake(0, 0, 84 * 2, 25);
        [_segment setCenter:CGPointMake(kScreen_Width / 2, 25)];
        _segment.selectedSegmentIndex = 0;
        _segment.tintColor = [UIColor lightGrayColor];
        [_segment addTarget:self action:@selector(segmentChange:) forControlEvents:UIControlEventValueChanged];
    }
    return _segment;
}

- (UIView*)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(20, 64, kScreen_Width - 20 - 50 - 2 * 15, 0.5)];
        _lineView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
    }
    return _lineView;
}

- (UIButton*)periodButton {
    if (!_periodButton) {
        _periodButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _periodButton.frame = CGRectMake(0, 0, 84, 20);
        _periodButton.backgroundColor = [UIColor whiteColor];
        [_periodButton setCenter:CGPointMake(kScreen_Width / 2, 64)];
        _periodButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_periodButton setTitleColor:[UIColor colorWithWhite:0.5 alpha:1.0] forState:UIControlStateNormal];
        [self configForButton:_periodButton withTitleString:@"本年" withImageString:@"user_gray_selectDateRange" withSpace:5.0f];
        [_periodButton addTarget:self action:@selector(periodButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _periodButton;
}

- (UIButton*)conditionButton {
    if (!_conditionButton) {
        _conditionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _conditionButton.frame = CGRectMake(kScreen_Width - 15 - 50, 0, 50, 20);
        _conditionButton.backgroundColor = [UIColor whiteColor];
        [_conditionButton setCenterY:_periodButton.center.y];
        
        _conditionButton.layer.borderWidth = 1.0;
        _conditionButton.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:1.0].CGColor;
        _conditionButton.layer.cornerRadius = 10;
        _conditionButton.clipsToBounds = YES;
        
        _conditionButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [_conditionButton setTitleColor:[UIColor colorWithWhite:0.5 alpha:1.0] forState:UIControlStateNormal];
        [self configForButton:_conditionButton withTitleString:@"筛选" withImageString:@"usernew_dashboard_list_screeningbutton" withSpace:2];
        
        [_conditionButton addTarget:self action:@selector(conditionButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _conditionButton;
}
@end
