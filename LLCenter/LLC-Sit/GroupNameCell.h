//
//  GroupNameCell.h
//  lianluozhongxin
//
//  Created by Vescky on 14-7-7.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupNameCell : UITableViewCell {
    IBOutlet UILabel *labelName;
    IBOutlet UIImageView *imgView;
}

- (void)setCellDataInfo:(CellDataInfo*)cInfo;

- (void)setGroupName:(NSString*)gName;

- (bool)getIsCellSelected;
- (void)setIsCellSelected:(bool)isSelected;


@end
