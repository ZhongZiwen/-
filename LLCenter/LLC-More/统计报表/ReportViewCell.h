//
//  ReportViewCell.h
//  lianluozhongxin
//
//  Created by Vescky on 14-6-18.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportViewCell : UITableViewCell {
    IBOutlet UILabel *labelName;
    IBOutlet UIView *view_line;
}

- (void)setCellDataInfo:(CellDataInfo*)cInfo;
// UI 适配
-(void)setCellViewFrame;
@end
