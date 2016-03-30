//
//  InfoCollectionCell.m
//  shangketong
//
//  Created by 蒋 on 16/2/17.
//  Copyright (c) 2016年 sungoin. All rights reserved.
//

#import "InfoCollectionCell.h"
#import "CommonFuntion.h"
@implementation InfoCollectionCell

- (void)awakeFromNib {
    // Initialization code
}

- (IBAction)showContactNameAction:(UISwitch *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowName" object:sender];
}

- (void)setFrameForAllPhone {
        CGFloat vX = kScreen_Width - 320;
        _topicLabel.frame = [CommonFuntion setViewFrameOffset:_topicLabel.frame byX:0 byY:0 ByWidth:vX byHeight:0];
        _topicNameLabel.frame = [CommonFuntion setViewFrameOffset:_topicNameLabel.frame byX:0 byY:0 ByWidth:vX byHeight:0];
        _groupNameLabel.frame = [CommonFuntion setViewFrameOffset:_groupNameLabel.frame byX:0 byY:0 ByWidth:vX byHeight:0];
        _showSwitch.frame = [CommonFuntion setViewFrameOffset:_showSwitch.frame byX:vX byY:0 ByWidth:0 byHeight:0];
        _deleteBtn.frame = [CommonFuntion setViewFrameOffset:_deleteBtn.frame byX:0 byY:0 ByWidth:vX byHeight:0];
}
@end
