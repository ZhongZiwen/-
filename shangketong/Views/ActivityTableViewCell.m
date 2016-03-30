//
//  VisitingTableViewCell.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/17.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ActivityTableViewCell.h"
#import "ActivityItem.h"
#import "NSString+Common.h"

@interface ActivityTableViewCell ()

@property (nonatomic, strong) UILabel *content;
@property (nonatomic, strong) UILabel *belongName;
@property (nonatomic, strong) UILabel *groupName;
@property (nonatomic, strong) UILabel *time;
@end

@implementation ActivityTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.contentView addSubview:self.content];
        [self.contentView addSubview:self.belongName];
        [self.contentView addSubview:self.groupName];
        [self.contentView addSubview:self.time];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(_belongName.frame.origin.x, _time.frame.origin.y, 100, 20)];
        label.font = [UIFont systemFontOfSize:14];
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = [UIColor lightGrayColor];
        label.text = @"时间";
        [self.contentView addSubview:label];
    }
    return self;
}

- (void)configWithItem:(ActivityItem *)item {
    
    _content.text = item.m_content;
    _belongName.text = [NSString stringWithFormat:@"来自%@", item.m_groupBelongName];
    _groupName.text = item.m_groupName;
    _time.text = [NSString transDateWithTimeInterval:item.m_time andCustomFormate:@"yyyy-MM-dd HH:mm"];
}

+ (CGFloat)cellHeightWithItem:(ActivityItem *)item {
    return 100;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - setters and getters
- (UILabel*)content {
    if (!_content) {
        _content = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, kScreen_Width - 20, 30)];
        _content.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
        _content.textAlignment = NSTextAlignmentLeft;
        _content.textColor = [UIColor blackColor];
    }
    return _content;
}

- (UILabel*)belongName {
    if (!_belongName) {
        _belongName = [[UILabel alloc] initWithFrame:CGRectMake(10, 10 + 30 + 5, 100, 20)];
        _belongName.font = [UIFont systemFontOfSize:14];
        _belongName.textAlignment = NSTextAlignmentLeft;
        _belongName.textColor = [UIColor lightGrayColor];
        
    }
    return _belongName;
}

- (UILabel*)groupName {
    if (!_groupName) {
        _groupName = [[UILabel  alloc] initWithFrame:CGRectMake(_belongName.frame.origin.x + CGRectGetWidth(_belongName.bounds) + 5, _belongName.frame.origin.y, kScreen_Width - 20- 5 - CGRectGetWidth(_belongName.bounds), 20)];
        _groupName.font = [UIFont systemFontOfSize:14];
        _groupName.textAlignment = NSTextAlignmentLeft;
        _groupName.textColor = [UIColor lightGrayColor];
    }
    return _groupName;
}

- (UILabel*)time {
    if (!_time) {
        _time = [[UILabel alloc] initWithFrame:CGRectMake(_groupName.frame.origin.x, _groupName.frame.origin.y + CGRectGetHeight(_groupName.bounds) + 5, CGRectGetWidth(_groupName.bounds), 20)];
        _time.font = [UIFont systemFontOfSize:14];
        _time.textAlignment = NSTextAlignmentLeft;
        _time.textColor = [UIColor lightGrayColor];
    }
    return _time;
}

@end
