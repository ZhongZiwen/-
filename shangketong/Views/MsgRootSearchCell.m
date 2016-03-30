//
//  MsgRootSearchCell.m
//  shangketong
//
//  Created by 蒋 on 15/11/20.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "MsgRootSearchCell.h"
#import "CommonFuntion.h"
#import "Hearder_View.h"

@interface MsgRootSearchCell ()

@property (nonatomic, strong) Hearder_View *headerView;

@end
@implementation MsgRootSearchCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)configWithDict:(NSArray *)array withIsMore:(NSString *)moreString {
    NSLog(@"是否包含----%d", [[self.contentView subviews] containsObject:_headerView]);
    if (![[self.contentView subviews] containsObject:_headerView]) {
        _headerView = [[Hearder_View alloc] initWithFrame:_imgIcon.frame];
        [self.contentView addSubview:_headerView];
    }
    NSDictionary *dict = [NSDictionary dictionaryWithDictionary:array[0]];
    if ([moreString isEqualToString:@"1"]) {
        _contentLabel.text = [NSString stringWithFormat:@"%ld条相关聊天记录", array.count];
    } else {
        _contentLabel.text = [dict safeObjectForKey:@"content"];
    }
    _titleLabel.text = [dict safeObjectForKey:@"groupName"];
    _dateLabel.hidden = YES;
    NSArray *iconArray = [dict objectForKey:@"icons"];
    if (iconArray.count > 1) {
        [_headerView customImageViews:iconArray];
        _imgIcon.hidden = YES;
    } else if (iconArray.count == 1) {
        [_imgIcon sd_setImageWithURL:[NSURL URLWithString:iconArray[0]] placeholderImage:[UIImage imageNamed:@"user_icon_default"]];
    } else {
        _imgIcon.image = [UIImage imageNamed:@"user_icon_default"];
    }
}

//更多结果使用
- (void)configWithDict:(NSDictionary *)dict {
//    NSLog(@"更多结果是否包含----%d", [[self.contentView subviews] containsObject:_headerView]);
    if (![[self.contentView subviews] containsObject:_headerView]) {
        _headerView = [[Hearder_View alloc] initWithFrame:_imgIcon.frame];
        [self.contentView addSubview:_headerView];
    }
    _contentLabel.text = [dict safeObjectForKey:@"content"];
    _titleLabel.text = [dict safeObjectForKey:@"groupName"];
    _imgIcon.backgroundColor = [UIColor redColor];
    NSString *dateSting = [CommonFuntion getStringForTime:[[dict safeObjectForKey:@"msgTime"] longLongValue]];
    _dateLabel.text = [dateSting substringWithRange:NSMakeRange(2, 8)];
    
    NSArray *iconArray = [dict objectForKey:@"icons"];
    if (iconArray.count > 1) {
        [_headerView customImageViews:iconArray];
        _imgIcon.hidden = YES;
    } else if (iconArray.count == 1) {
        [_imgIcon sd_setImageWithURL:[NSURL URLWithString:iconArray[0]] placeholderImage:[UIImage imageNamed:@"user_icon_default"]];
    } else {
        _imgIcon.image = [UIImage imageNamed:@"user_icon_default"];
    }
}
- (void)setFrameForAlliPhone {
    NSInteger vX = kScreen_Width - 320;
    _dateLabel.frame = [CommonFuntion setViewFrameOffset:_dateLabel.frame byX:vX byY:0 ByWidth:0 byHeight:0];
}
@end
