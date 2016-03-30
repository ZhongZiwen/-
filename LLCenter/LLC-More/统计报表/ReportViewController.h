//
//  ReportViewController.h
//  lianluozhongxin
//  统计报表
//  Created by Vescky on 14-6-16.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportViewController : AppsBaseViewController {
    IBOutlet UITableView *tbView;
    IBOutlet UIView *viewForNavigation,*bottomView,*bottomViewSecond;
    IBOutlet UITableViewCell *cellTotalCount;
    IBOutlet UILabel *labelTotalTimes,*labelTotalDuration,*labelNoContent;
    NSMutableArray *dataSource;
    
    // 顶部View按钮 上下排
    IBOutlet UIButton *btnHead10,*btnHead11,*btnHead12,*btnHead13;
    IBOutlet UIButton *btnHead20,*btnHead21,*btnHead22,*btnHead23;
    
    // 底部按钮View
    IBOutlet UIButton *btnOToday,*BtnOWeek,*btnOMonth,*btnOYear;
    IBOutlet UIButton *BtnTWeek,*btnTMonth,*btnTYear;
    
    IBOutlet UIView *viewO,*viewT;
    
}

- (IBAction)btnAction:(id)sender;

@end
