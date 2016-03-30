//
//  OutCallLineViewController.h
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-9-14.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AppsBaseViewController.h"

@interface OutCallLineViewController : AppsBaseViewController

@property (strong, nonatomic) IBOutlet UILabel *labelTile;

///单向
@property (strong, nonatomic) IBOutlet UIButton *btnOneWay;
@property (strong, nonatomic) IBOutlet UILabel *labelOneWayTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelOneWayReadMe;


@property (strong, nonatomic) IBOutlet UIImageView *imgLine;



///双向
@property (strong, nonatomic) IBOutlet UIButton *btnTwoWay;
@property (strong, nonatomic) IBOutlet UILabel *labelTwoWayTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelTwoWayReadMe;


@property (strong, nonatomic) IBOutlet UIImageView *imgLine2;


@end
