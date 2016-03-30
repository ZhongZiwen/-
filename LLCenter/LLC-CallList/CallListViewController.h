//
//  CallListViewController.h
//  lianluozhongxin
//
//  Created by Vescky on 14-6-16.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CallListViewController : AppsBaseViewController {
    NSMutableArray *dataSource;//数据
    IBOutlet UITableView *tbView;
    IBOutlet UIView *topView;
    IBOutlet UILabel *labelNoContent;
    IBOutlet UIScrollView *scView;
    
    
    IBOutlet UIView *view_top_line;
    
    IBOutlet UIButton *btnSeg10,*btnSeg11,*btnSeg12,*btnSeg13;
    IBOutlet UIButton *btnSeg20,*btnSeg21,*btnSeg22,*btnSeg23;
    
}

- (IBAction)btnAction:(id)sender;

@end
