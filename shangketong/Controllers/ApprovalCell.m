//
//  ApprovalCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/31.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ApprovalCell.h"
#import "NSString+Common.h"
#import "UIView+Common.h"
#import "Approval.h"
#import <UIImageView+WebCache.h>

#define kStatusLabelWidth    50

@interface ApprovalCell ()

@property (nonatomic, strong) UIImageView *headView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@end

@implementation ApprovalCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.contentView addSubview:self.headView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.detailLabel];
        [self.contentView addSubview:self.statusLabel];
    }
    return self;
}

- (void)configWithModel:(Approval *)approval andApprovalType:(NSInteger)approvalType {
    _nameLabel.text = [NSString stringWithFormat:@"%@[%@]", approval.m_flowName, approval.m_approveNo];
    
//    NSString *iconString = @"";
//    if (approvalType == 1) {
//        iconString = approval.m_approverIcon;
//    }else {
//        iconString = approval.m_creatIcon;
//    }
    
    if (approvalType == 0) {
        _headView.hidden = YES;
        
        [_nameLabel setX:15];
        [_detailLabel setX:15];
    }else {
        _headView.hidden = NO;
        [_headView sd_setImageWithURL:[NSURL URLWithString:approval.m_approverIcon] placeholderImage:[UIImage imageNamed:@"user_icon_default"]];
        
        [_nameLabel setX:70];
        [_detailLabel setX:70];
    }
    
    [_detailLabel setWidth:kScreen_Width-140];
    
    
    /*
     3.0.3需求
    已通过、已撤回、已拒绝的审批需要在列表页右侧显示最新的审批状态，绿色代表已通过，黄色代表已撤回，红色代表拒绝，等待审批的不需显示；
     */
    
    
    ///我提交的/全部：1-审批中 2-已撤回 3-已通过 4-已拒绝
    if (approvalType == 0 || approvalType == 2) {
        if (approval.m_approveStatus == 1) {   // 等待审批
            _detailLabel.text = [NSString stringWithFormat:@"%@ 等待 %@审批", [self changeTime:approval.m_reviewTime], approval.m_approverName];
            
            ///等待审批不用显示状态
            _statusLabel.hidden = YES;
            _statusLabel.text = @"审批中";
            _statusLabel.layer.borderColor = [UIColor redColor].CGColor;
            _statusLabel.textColor = [UIColor redColor];
            
        }else if (approval.m_approveStatus == 2) {
            _detailLabel.text = [self changeTime:approval.m_reviewTime];
            
            _statusLabel.hidden = NO;
            _statusLabel.text = @"已撤回";
            _statusLabel.layer.borderColor = SKT_OA_APPROVAL_STATUS_YELLOW.CGColor;
            _statusLabel.textColor = SKT_OA_APPROVAL_STATUS_YELLOW;
            
        }else if (approval.m_approveStatus == 3) {
            _detailLabel.text = [self changeTime:approval.m_reviewTime];
            _statusLabel.hidden = NO;
            _statusLabel.text = @"已通过";
            _statusLabel.layer.borderColor = SKT_OA_APPROVAL_STATUS_GREEN.CGColor;
            _statusLabel.textColor = SKT_OA_APPROVAL_STATUS_GREEN;
            
        }else if (approval.m_approveStatus == 4) {
            _detailLabel.text = [NSString stringWithFormat:@"%@ 被 %@拒绝", [self changeTime:approval.m_reviewTime], approval.m_approverName];
            
            _statusLabel.hidden = NO;
            _statusLabel.text = @"已拒绝";
            _statusLabel.layer.borderColor = SKT_OA_APPROVAL_STATUS_RED.CGColor;
            _statusLabel.textColor = SKT_OA_APPROVAL_STATUS_RED;
        }
    }else if (approvalType == 1){
        ///提交给我的：-1待审批 0:拒绝 1:通过（我只判断了-1，1和2状态显示空）
        
        if (approval.m_approveStatus == -1) {
            _detailLabel.text = [NSString stringWithFormat:@"%@ 等待 %@审批", [self changeTime:approval.m_reviewTime], approval.m_approverName];
            
            ///等待审批不用显示状态
            _statusLabel.hidden = YES;
            _statusLabel.text = @"待审批";
            _statusLabel.layer.borderColor = [UIColor redColor].CGColor;
            _statusLabel.textColor = [UIColor redColor];
            
            
        }else if (approval.m_approveStatus == 0) {
            _detailLabel.text = [NSString stringWithFormat:@"%@ 被 %@拒绝", [self changeTime:approval.m_reviewTime], approval.m_approverName];
            
            _statusLabel.hidden = NO;
            _statusLabel.text = @"已拒绝";
            _statusLabel.layer.borderColor = SKT_OA_APPROVAL_STATUS_RED.CGColor;
            _statusLabel.textColor = SKT_OA_APPROVAL_STATUS_RED;
            
        }else if (approval.m_approveStatus == 1) {
            _detailLabel.text = [self changeTime:approval.m_reviewTime];//[NSString msgRemindApprovalTransDateWithTimeInterval:approval.m_createdTime];
            _statusLabel.hidden = YES;
            
            _statusLabel.hidden = NO;
            _statusLabel.text = @"已同意";
            _statusLabel.layer.borderColor = SKT_OA_APPROVAL_STATUS_GREEN.CGColor;
            _statusLabel.textColor = SKT_OA_APPROVAL_STATUS_GREEN;
        }
    }
}

+ (CGFloat)cellHeight {
    return 60.0f;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - setters and getters
- (UIImageView*)headView {
    if (!_headView) {
        _headView =[[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 40, 40)];
        _headView.contentMode = UIViewContentModeScaleAspectFill;
        _headView.clipsToBounds = YES;
        
    }
    return _headView;
}

- (UILabel*)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, kScreen_Width-130, 20)];
        _nameLabel.font = [UIFont systemFontOfSize:14];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _nameLabel;
}

- (UILabel*)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, kScreen_Width-130, 20)];
        _detailLabel.font = [UIFont systemFontOfSize:12];
        _detailLabel.textColor = [UIColor lightGrayColor];
        _detailLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _detailLabel;
}

- (UILabel*)statusLabel {
    if (!_statusLabel) {
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width - 10 - kStatusLabelWidth, ([ApprovalCell cellHeight] - 20) / 2.0, kStatusLabelWidth, 20)];
        _statusLabel.font = [UIFont systemFontOfSize:12];
        _statusLabel.layer.cornerRadius = 2;
        _statusLabel.layer.borderWidth = 0.5;
        _statusLabel.layer.masksToBounds = YES;
        _statusLabel.clipsToBounds = YES;
        _statusLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _statusLabel;
}
- (NSString *)changeTime:(NSString *)longTime{
    NSDate *lastDate = [[NSDate alloc] initWithTimeIntervalSince1970:[longTime longLongValue] / 1000.0];
    
    NSString *dateStr;      // 年月日
    NSString *hour;         // 时
    if ([lastDate year] == [[NSDate date] year]) {  // 今年
        NSInteger days = [CommonFuntion getTimeDaysSinceToady:[CommonFuntion getStringForTime:[longTime longLongValue]]];
        if (days == 0) {
            dateStr = @"今天";
        } else if (days == 1) {
            dateStr = @"昨天";
        } else {     // 非今天或昨天 显示xx月xx日
            dateStr = [lastDate stringMonthDay];
        }
    }
    hour = [NSString stringWithFormat:@"%02d",(int)[lastDate hour]];
    
    return [NSString stringWithFormat:@"%@ %@:%02d",dateStr,hour,(int)[lastDate minute]];
    
}

@end
