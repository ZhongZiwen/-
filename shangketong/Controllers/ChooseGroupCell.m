//
//  ChooseGroupCell.m
//  shangketong
//
//  Created by 蒋 on 15/9/16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ChooseGroupCell.h"
#import "ConversationListModel.h"
@implementation ChooseGroupCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)configWithModel:(ConversationListModel *)model withImgArray:(NSArray *)imgArray {
    _groupImageView.hidden = YES;
    
    if (!_headerView) {
        _headerView = [[Hearder_View alloc] initWithFrame:_groupImageView.frame];
    }
    [_headerView customImageViews:imgArray];
    _groupNameLabel.text = model.b_name;
    [self.contentView addSubview:_headerView];
}
@end
