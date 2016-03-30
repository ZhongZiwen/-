//
//  GroupNameCell.m
//  lianluozhongxin
//
//  Created by Vescky on 14-7-7.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import "GroupNameCell.h"

@interface GroupNameCell () {
    bool isCellSelected;
}
@end

@implementation GroupNameCell

- (void)setCellDataInfo:(CellDataInfo*)cInfo {
    [self setGroupName:[cInfo.cellDataInfo safeObjectForKey:@"groupName"]];
    [self setIsCellSelected:[[cInfo.cellDataInfo safeObjectForKey:@"isSelected"] boolValue]];
    imgView.hidden = YES;
    if (isCellSelected) {
        self.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        self.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (void)setGroupName:(NSString*)gName {
    labelName.text = gName;
}

- (void)setIsCellSelected:(bool)isSelected {
//    imgView.hidden = !isSelected;
    isCellSelected = isSelected;
}

- (bool)getIsCellSelected {
    return isCellSelected;
}

@end
