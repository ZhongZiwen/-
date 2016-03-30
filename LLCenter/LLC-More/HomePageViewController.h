//
//  HomePageViewController.h
//  lianluozhongxin
//
//  Created by Vescky on 14-6-16.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomePageViewController : AppsBaseViewController {
    IBOutlet UIImageView *imgv_bg;
    IBOutlet UITableView *tbView;
    NSMutableArray *dataSource;
}

//检查版本信息
- (void)getDataFromServer ;
@end
