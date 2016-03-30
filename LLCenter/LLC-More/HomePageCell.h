//
//  HomePageCell.h
//  lianluozhongxin
//
//  Created by Vescky on 14-6-18.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomePageCell : UITableViewCell {
    IBOutlet UIImageView *imgvIcon,*imgvExpand;
    IBOutlet UILabel *labelItemName,*labelItemContent;
    IBOutlet UILabel *labelDetail1,*labelDetail2,*labelDetail3,*labelDetail4,*labelDetail5;
    IBOutlet UIView *expandedView,*view_line;
    
    
    IBOutlet UILabel *labelTag1,*labelTag2,*labelTag3,*labelTag4,*labelTag5;
    
    IBOutlet UIButton *btnExBg;
}

- (void)setCellDataInfo:(CellDataInfo*)cInfo;

- (float)getCellHeight:(CellDataInfo*)cInfo;

- (void)setButtonSelected:(bool)isSelected;


// UI 适配
-(void)setCellViewFrame;
@end
