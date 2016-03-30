//
//  MsgChatTableViewCell.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#define kImageView_Width    44
#define kTimeLabel_Width    64

#import "MsgChatTableViewCell.h"
#import "CommonFuntion.h"
#import "ConversationListModel.h"
#import "Hearder_View.h"
#import <UIImageView+WebCache.h>
#import "ChatMessage.h"
#import "ContactModel.h"
#import "IM_FMDB_FILE.h"
#import "AFNHttp.h"

@interface MsgChatTableViewCell ()

@property (nonatomic, strong) UIImageView *m_imageView;
@property (nonatomic, strong) UILabel *m_titleLabel;
@property (nonatomic, strong) UILabel *m_timeLabel;
@property (nonatomic, strong) UIButton *countbtn; //未读消息数

@property (nonatomic, strong) Hearder_View *headerView;

@end

@implementation MsgChatTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _m_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, ([MsgChatTableViewCell cellHeight]-kImageView_Width)/2.0f, kImageView_Width, kImageView_Width)];
        _m_imageView.contentMode = UIViewContentModeScaleAspectFill;
        _m_imageView.clipsToBounds = YES;
        [self.contentView addSubview:_m_imageView];
        
        _m_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2*_m_imageView.frame.origin.x+kImageView_Width, _m_imageView.frame.origin.y, kScreen_Width-_m_imageView.frame.origin.x-kImageView_Width-15-kTimeLabel_Width-10, 24)];
        _m_titleLabel.font = [UIFont systemFontOfSize:16];
        _m_titleLabel.textColor = [UIColor blackColor];
        _m_titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_m_titleLabel];
    
        _m_detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(_m_titleLabel.frame.origin.x, _m_titleLabel.frame.origin.y+CGRectGetHeight(_m_titleLabel.bounds), CGRectGetWidth(_m_titleLabel.bounds), 20)];
        _m_detailLabel.font = [UIFont systemFontOfSize:14];
        _m_detailLabel.textColor = [UIColor lightGrayColor];
        _m_detailLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_m_detailLabel];
        
        _m_timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width-10-kTimeLabel_Width, ([MsgChatTableViewCell cellHeight]-20)/2.0f, kTimeLabel_Width, 20)];
        _m_timeLabel.font = [UIFont systemFontOfSize:10];
        _m_timeLabel.textColor = [UIColor lightGrayColor];
        _m_timeLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_m_timeLabel];
        
        _countbtn = [[UIButton alloc] initWithFrame:CGRectMake(_m_imageView.frame.size.width + 10 - 10, _m_imageView.frame.origin.y - 10, 20, 20)];
        _countbtn.titleLabel.font = [UIFont systemFontOfSize:8];
        _countbtn.titleLabel.tintColor = [UIColor whiteColor];
        _countbtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        _countbtn.layer.masksToBounds = YES;
        _countbtn.layer.cornerRadius = 10;
        _countbtn.userInteractionEnabled = NO;
        [_countbtn setBackgroundImage:[CommonFuntion createImageWithColor:[UIColor redColor]] forState:UIControlStateNormal];
        _headerView = [[Hearder_View alloc] initWithFrame:_m_imageView.frame];
        [self.contentView addSubview:_headerView];
    }
    return self;
}
- (void)configWithModel:(ConversationListModel *)model {
    NSString *titleStr = model.b_name;
    if ([model.b_type isEqualToString:@"0"]) {
      NSArray *userArray = [IM_FMDB_FILE result_IM_UserList:model.b_id];
        for (ContactModel *conModel in userArray) {
            if (conModel.userID != [appDelegateAccessor.moudle.userId integerValue]) {
               model.b_name = titleStr = conModel.contactName;
            }
        }
//        if ([titleArray containsObject:appDelegateAccessor.moudle.userName]) {
//            [titleArray removeObjectAtIndex:[titleArray indexOfObject:appDelegateAccessor.moudle.userName]];
//        }
//        
//        if (titleArray.count > 1) {
//            titleStr = [titleArray componentsJoinedByString:@","];
//        } else {
//            titleStr = titleArray[0];
//        }
    }
    _m_titleLabel.text = titleStr;
    
    NSString *contactName = @"";
    for (ContactModel *chatModel in [IM_FMDB_FILE result_IM_UserList:model.b_id]) {
        if (chatModel.userID == [model.m_userId integerValue]) {
            contactName = chatModel.contactName;
        }
    }
    if (model.isHave) {
        NSString *typeString = @"";
        if ([model.r_type isEqualToString:@"1"]) {
            typeString = @"图片";
        } else if ([model.r_type isEqualToString:@"3"]) {
            typeString = @"语音";
        } else {
            typeString = @"文件";
        }
        if ([model.b_type isEqualToString:@"1"]) {
            if ([model.m_content hasPrefix:@"[草稿]"]) {
                NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:model.m_content];
                [attString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Heiti SC" size:13] range:NSMakeRange(0, 4)];
                [attString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, 4)];
                _m_detailLabel.attributedText = attString;
            } else {
                _m_detailLabel.text = [NSString stringWithFormat:@"%@:[%@]", contactName, typeString];
            }
        } else {
            if ([model.m_content hasPrefix:@"[草稿]"]) {
                NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:model.m_content];
                [attString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Heiti SC" size:13] range:NSMakeRange(0, 4)];
                [attString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, 4)];
                _m_detailLabel.attributedText = attString;
            } else {
                _m_detailLabel.text = typeString;
            }

        }
    } else {
        if ([model.b_type isEqualToString:@"1"]) {
            
            //消息类型 消息类 system: 0系统消息  text: 1文本类型  create: 2创建组 join: 3加入组 exit: 4退出组  update:5修改组
            if ([model.m_type isEqualToString:@"4"]) {
                _m_detailLabel.text = model.m_content;
            } else {
                NSString *messageTypeStr = @"";
                if ([model.m_type isEqualToString:@"3"] || [model.m_type isEqualToString:@"5"]) {
                    messageTypeStr = @"把";
                } else {
                    messageTypeStr = @":";
                }
                if ([model.m_content hasPrefix:@"[草稿]"]) {
                    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:model.m_content];
                    [attString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Heiti SC" size:13] range:NSMakeRange(0, 4)];
                    [attString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, 4)];
                    _m_detailLabel.attributedText = attString;
                } else {
                    _m_detailLabel.text = [NSString stringWithFormat:@"%@%@%@", contactName, messageTypeStr, model.m_content];
                }
                
            }
            
        } else {
            if ([model.m_content hasPrefix:@"[草稿]"]) {
                NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:model.m_content];
                [attString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Heiti SC" size:13] range:NSMakeRange(0, 4)];
                [attString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, 4)];
                _m_detailLabel.attributedText = attString;
            } else {
                _m_detailLabel.text = model.m_content;
            }
        }
//        _m_detailLabel.text = [NSString stringWithFormat:@"%@:[%@]", contactName, model.m_content];
    }
    
    if ([model.b_unReadNumber isEqualToString:@"0"]) {
        _countbtn.hidden = YES;
    } else {
        if ([model.b_unReadNumber integerValue] > 99) {
            model.b_unReadNumber = @"99+";
        }
        [_countbtn setTitle:model.b_unReadNumber forState:UIControlStateNormal];
        _countbtn.hidden = NO;
    }
    NSString *timeStr = [CommonFuntion getStringForTime:[model.m_lastMessageTime longLongValue]];
    NSInteger value = [CommonFuntion getTimeDaysSinceToady:timeStr];
    if (value == 0) {
        timeStr = [timeStr substringWithRange:NSMakeRange(11, 5)];
    } else if (value == 1) {
        timeStr = @"昨天";
    }
//        else if (value > 1 && value <=7) {
//        NSArray *weekDaysArray = @[@"星期日", @"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"星期六"];
//        NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:[model.m_lastMessageTime longLongValue] / 1000];
//        NSInteger index = [CommonFuntion getCurDateWeekday:date];
//        timeStr = [weekDaysArray objectAtIndex:index - 1];
//    }
    else {
        timeStr = [timeStr substringToIndex:10];
    }
    _m_timeLabel.text = timeStr;
    NSArray *userArray = [NSArray arrayWithArray:[IM_FMDB_FILE result_IM_UserList:model.b_id]];
    NSMutableArray *imgsArray = [NSMutableArray arrayWithCapacity:0];
    for (ContactModel *userModel in userArray) {
        if ([model.b_type isEqualToString:@"0"]) {
            if (userModel.userID != [appDelegateAccessor.moudle.userId integerValue]) {
                [imgsArray addObject:userModel.imgHeaderName];
            }
        } else {
            [imgsArray addObject:userModel.imgHeaderName];
        }
    }
    if ([model.b_type isEqualToString:@"1"]) {
        _m_imageView.hidden = YES;
        _headerView.hidden = NO;
        [_headerView customImageViews:imgsArray];
    } else {
        _m_imageView.hidden = NO;
        _headerView.hidden = YES;
//        if (imgsArray && imgsArray.count > 0) { //
//            [_m_imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", GET_IM_ICON_URL, imgsArray[0]]] placeholderImage:[UIImage imageNamed:@"user_icon_default"]];
//        }else {
//            _m_imageView.image = [UIImage imageNamed:@"user_icon_default"];
//        }
        if (imgsArray && imgsArray.count > 0) { //
            [_m_imageView sd_setImageWithURL:[NSURL URLWithString:imgsArray[0]]placeholderImage:[UIImage imageNamed:@"user_icon_default"]];
        }else {
            _m_imageView.image = [UIImage imageNamed:@"user_icon_default"];
        }
    }
    [self.contentView addSubview:_countbtn];
}
+(CGFloat)cellHeight {
    return 64.0f;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
