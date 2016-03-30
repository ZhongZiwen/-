//
//  ContactBookCell.h
//  lianluozhongxin
//
//  Created by Vescky on 14-6-24.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactBookCell : UITableViewCell {
    IBOutlet UITableView *tbView;
    IBOutlet UILabel *labelTitle;
    IBOutlet UIButton *btnExpand;
    
    IBOutlet UIView *view_headview,*view_headline;
    
    NSMutableArray *dataSource;
}

@property (nonatomic,strong) UIViewController *parentViewController;

- (void)setCellDataInfo:(CellDataInfo*)cInfo;

-(void)setCellViewFrame;

@end
