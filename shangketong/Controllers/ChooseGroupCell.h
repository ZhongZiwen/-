//
//  ChooseGroupCell.h
//  shangketong
//
//  Created by 蒋 on 15/9/16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Hearder_View.h"

@class ConversationListModel;
@interface ChooseGroupCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *groupImageView;

@property (nonatomic, strong) Hearder_View *headerView;

- (void)configWithModel:(ConversationListModel *)model withImgArray:(NSArray *)imgArray;
@end
