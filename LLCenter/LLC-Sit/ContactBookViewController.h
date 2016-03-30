//
//  ContactBookViewController.h
//  lianluozhongxin
//
//  Created by Vescky on 14-6-24.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactBookViewController : AppsBaseViewController {
    IBOutlet UITableView *tbView;
    IBOutlet UILabel *labelTips;
    NSMutableArray *dataSource;
}



@end
