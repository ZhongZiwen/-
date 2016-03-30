//
//  TaskTableViewCell.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/11.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "TaskTableViewCell.h"
#import "TaskMember.h"
#import "NSString+Common.h"
#import "UILabelStrikeThrough.h"
#import "CommonConstant.h"
#import "CommonFuntion.h"
@interface TaskTableViewCell ()

@property (nonatomic, strong) UIButton *m_selectButton;
@property (nonatomic, strong) UILabelStrikeThrough *m_titleLabel;
@property (nonatomic, strong) UILabel *m_detailLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, assign) NSInteger flag; //区分btn图片+点击事件
@property (nonatomic, strong) UILabelStrikeThrough *newTitleLabel;

@property (nonatomic, assign) long long taskID; //获取任务ID
@end

@implementation TaskTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.contentView addSubview:self.m_selectButton];
        [self.contentView addSubview:self.m_titleLabel];
        [self.contentView addSubview:self.m_detailLabel];
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.newTitleLabel];
    }
    return self;
}

- (void)configWithItem:(TaskMember *)item {
    CGFloat width = 0.0;
    NSString *newName = @"";
    if (item.taskStatus == 6 || item.taskStatus == 5) {
        newName = [NSString stringWithFormat:@"%@-%@", item.ownerName, item.taskName];
        _m_titleLabel.text = newName;
        _newTitleLabel.text = newName;
    } else {
        newName = item.taskName;
        _m_titleLabel.text = item.taskName;
        _newTitleLabel.text = item.taskName;
    }
    if (newName && newName.length > 0) {
       width = [newName getWidthWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(MAXFLOAT, 30)];
    }
    CGRect frame = _m_titleLabel.frame;
    if (width < (kScreen_Width - CGRectGetWidth(_m_selectButton.bounds) - 10 - 80 - 10)) {
        frame.size.width = width;
    }else {
        frame.size.width = kScreen_Width - CGRectGetWidth(_m_selectButton.bounds) - 10 - 80 - 10;
    }
    _m_titleLabel.frame = frame;
    _newTitleLabel.frame = CGRectMake(_newTitleLabel.frame.origin.x, _newTitleLabel.frame.origin.y, frame.size.width, _newTitleLabel.frame.size.height);
    
    /*
     显示文本颜色+左边btn可不可以被点击
     isMine: 0 不可以点击
     isMine: !0 可点击
     "priority": 1,  一般 （黑色字体）
     "priority": 0,  重要（红色字体）
     */
    if (item.taskPriority == 0) {
        _m_titleLabel.textColor = [UIColor redColor];
        _newTitleLabel.textColor = [UIColor redColor];
    } else {
        _m_titleLabel.textColor = [UIColor blackColor];
        _newTitleLabel.textColor = [UIColor blackColor];
    }
    
    NSString *imgStr = @"";
    if (item.creatByUID == [appDelegateAccessor.moudle.userId longLongValue] || item.ownerByUID == [appDelegateAccessor.moudle.userId longLongValue]) {
        _m_selectButton.userInteractionEnabled = YES;
        if (item.taskStatus == 7) {
            _flag = item.taskStatus;
            _m_titleLabel.textColor = [UIColor lightGrayColor];
            _newTitleLabel.textColor = [UIColor lightGrayColor];
            _m_titleLabel.isWithStrikeThrough = YES;
            _newTitleLabel.isWithStrikeThrough = YES;
            imgStr = @"home_today_task_done";
        } else {
            _flag = item.taskStatus;
            _m_titleLabel.isWithStrikeThrough = NO;
            _newTitleLabel.isWithStrikeThrough = NO;
            if (item.taskStatus == 5 || item.taskStatus == 6) {
                imgStr = @"task_not_done_disable";
            } else {
                imgStr = @"home_today_task";
            }
        }
    } else {
        _m_selectButton.userInteractionEnabled = NO;
        if (item.taskStatus == 7) {
            _flag = item.taskStatus;
            _m_titleLabel.textColor = [UIColor lightGrayColor];
            _newTitleLabel.textColor = [UIColor lightGrayColor];
            _m_titleLabel.isWithStrikeThrough = YES;
            _newTitleLabel.isWithStrikeThrough = YES;
            imgStr = @"task_done_disable"; //更换图片
        } else {
            _flag = item.taskStatus;
            _m_titleLabel.isWithStrikeThrough = NO;
            _newTitleLabel.isWithStrikeThrough = NO;
            imgStr = @"task_not_done_disable"; //更换图片
        }
    }
    /*
    if (item.taskMine != 0) {
        _m_selectButton.userInteractionEnabled = YES;
        if (item.taskStatus == 7) {
            _flag = item.taskStatus;
            _m_titleLabel.textColor = [UIColor lightGrayColor];
            _newTitleLabel.textColor = [UIColor lightGrayColor];
            _m_titleLabel.isWithStrikeThrough = YES;
            _newTitleLabel.isWithStrikeThrough = YES;
            imgStr = @"home_today_task_done";
        } else {
            _flag = item.taskStatus;
            _m_titleLabel.isWithStrikeThrough = NO;
            _newTitleLabel.isWithStrikeThrough = NO;
            imgStr = @"home_today_task";
        }
    } else {
        _m_selectButton.userInteractionEnabled = NO;
        if (item.taskStatus == 7) {
            _flag = item.taskStatus;
            _m_titleLabel.textColor = [UIColor lightGrayColor];
            _newTitleLabel.textColor = [UIColor lightGrayColor];
            _m_titleLabel.isWithStrikeThrough = YES;
            _newTitleLabel.isWithStrikeThrough = YES;
            imgStr = @"task_done_disable"; //更换图片
        } else {
            _flag = item.taskStatus;
            _m_titleLabel.isWithStrikeThrough = NO;
            _newTitleLabel.isWithStrikeThrough = NO;
            imgStr = @"task_not_done_disable"; //更换图片
        }
    }
     */
    
    // 1 2 3 4 5 6 7
    //taskStatus 今天 明天 将来 已过期 待接收 被拒绝 已完成
    if (item.taskStatus == 7) {
        ///完成
        imgStr = @"task_icon_over.png";
    }else if (item.taskStatus == 4){
        ///过期
        imgStr = @"task_icon_invalid.png";
    }else{
        ///未完成
        imgStr = @"task_icon_notcompleted.png";
    }
//    [_m_selectButton setBackgroundImage:[UIImage imageNamed:imgStr] forState:UIControlStateNormal];
    [_m_selectButton setImage:[UIImage imageNamed:imgStr] forState:UIControlStateNormal];
    
    /*
     cell 内容显示区分
     1）"from”:不为空 +  belongName 不为空 +  name 不为空
     显示：来自+ belongName + name
     否则：_m_detailLabel 隐藏掉， _m_titleLabel 下移
     */
    if (item.from_belongName == nil || item.from_name == nil) {
        _m_detailLabel.hidden = YES;
        _m_titleLabel.hidden = YES;
        _newTitleLabel.hidden = NO;
    } else {
        _m_detailLabel.text = [NSString stringWithFormat:@"%@ %@", item.from_belongName, item.from_name];
        _m_detailLabel.hidden = NO;
        _m_titleLabel.hidden = NO;
        _newTitleLabel.hidden = YES;
    }
    _timeLabel.text = [[CommonFuntion getStringForTime:[item.taskDate longLongValue]] substringFromIndex:5];
//    _timeLabel.text = [NSString transDateWithTimeInterval:item.taskDate andCustomFormate:@"MM-dd HH:mm"];
    _taskID = [item.taskID longLongValue];
    
    ///添加左滑按钮
    [self addRightCellMenuBtn:item];
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

#pragma mark - event response
- (void)selectButtonPress:(UIButton*)sender {
    NSString *imgStr = @"";
    if (_flag == 5 || _flag == 6) {
        return;
    }
    if (_flag == 7) {
        imgStr = @"home_today_task";
        NSLog(@"已完成任务%ld", _flag);
    } else {
        imgStr = @"home_today_task_done";
        NSLog(@"待办任务%ld", _flag);
    }
    NSLog(@"----->移除数据");
    [sender setImage:[UIImage imageNamed:imgStr] forState:UIControlStateNormal];
    if (self.delegate && [self.delegate respondsToSelector:@selector(getTasksIDForChange:)]) {
        [self.delegate getTasksIDForChange:_taskID];
    }
}


#pragma mark - 左滑动按钮
-(void)addRightCellMenuBtn:(TaskMember *)item{
    // 1 2 3 4 5 6 7
    //taskStatus 1今天 2明天 3将来 4已过期 5待接收 6被拒绝 7已完成

    ///创建人
    BOOL isMe = FALSE;
    if (item.creatByUID == [appDelegateAccessor.moudle.userId longLongValue]) {
        isMe = TRUE;
    }
    
    ///负责 且已接收
    BOOL isResponsible = FALSE;
    if (item.ownerByUID == [appDelegateAccessor.moudle.userId longLongValue] && item.taskStatus != 5) {
        isResponsible = TRUE;
    }
    
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];

    ///创建人
    if (isMe) {
        ///已完成
        if (item.taskStatus == 7) {
            [rightUtilityButtons sw_addUtilityButtonWithColor:SKT_TASK_OR_SCHEDULE_MENU_BTN_COLOR_RESET title:@"重启"];
            [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor redColor] title:@"删除"];

        }else if (item.taskStatus == 6 || item.taskStatus == 5) {
            ///被拒绝
            [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor redColor] title:@"删除"];
        }else {
            [rightUtilityButtons sw_addUtilityButtonWithColor:SKT_TASK_OR_SCHEDULE_MENU_BTN_COLOR_OVER title:@"完成"];
            [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor redColor] title:@"删除"];
        }
        
    }else if(isResponsible){
        ///责任且已接收
        ///已完成
        if (item.taskStatus == 7) {
            [rightUtilityButtons sw_addUtilityButtonWithColor:SKT_TASK_OR_SCHEDULE_MENU_BTN_COLOR_RESET title:@"重启"];
        }else{
            [rightUtilityButtons sw_addUtilityButtonWithColor:SKT_TASK_OR_SCHEDULE_MENU_BTN_COLOR_OVER title:@"完成"];
        }
        
    }else{
        ///参与人
    }
    
    [self setRightUtilityButtons:rightUtilityButtons WithButtonWidth:60.0];
}


#pragma mark - setters and getters
- (UIButton*)m_selectButton {
    if (!_m_selectButton) {
        _m_selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _m_selectButton.frame = CGRectMake(0, 0, 49, [TaskTableViewCell cellHeight]);
//        [_m_selectButton addTarget:self action:@selector(selectButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _m_selectButton;
}

- (UILabel*)m_titleLabel {
    if (!_m_titleLabel) {
        _m_titleLabel = [[UILabelStrikeThrough alloc] initWithFrame:CGRectMake(CGRectGetWidth(_m_selectButton.bounds), 0, 0, 30)];
        _m_titleLabel.font = [UIFont systemFontOfSize:14];
        _m_titleLabel.textAlignment = NSTextAlignmentLeft;
        
    }
    return _m_titleLabel;
}

- (UILabel*)m_detailLabel {
    if (!_m_detailLabel) {
        _m_detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(_m_titleLabel.frame.origin.x, 30, 190, 30)];
        _m_detailLabel.font = [UIFont systemFontOfSize:12];
        _m_detailLabel.textColor = [UIColor lightGrayColor];
        _m_detailLabel.textAlignment = NSTextAlignmentLeft;
        
    }
    return _m_detailLabel;
}

- (UILabel*)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width - 10 - 100, ([TaskTableViewCell cellHeight]-20)/2.0, 100, 20)];
        _timeLabel.font = [UIFont systemFontOfSize:14];
        _timeLabel.textColor = [UIColor lightGrayColor];
        _timeLabel.textAlignment = NSTextAlignmentRight;
    }
    return _timeLabel;
}
- (UILabelStrikeThrough *)newTitleLabel {
    if (!_newTitleLabel) {
        _newTitleLabel = [[UILabelStrikeThrough alloc] initWithFrame:CGRectMake(CGRectGetWidth(_m_selectButton.bounds), 15, 0, 30)];
        _newTitleLabel.font = [UIFont systemFontOfSize:14];
        _newTitleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _newTitleLabel;
}
@end
