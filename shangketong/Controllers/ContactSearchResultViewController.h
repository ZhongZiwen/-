//
//  ContactSearchResultViewController.h
//  shangketong
//  联系人搜索结果页面
//  Created by sungoin-zjp on 15-6-16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactSearchResultViewController : UIViewController
@property(strong,nonatomic) UITableView *tableviewContact;
@property(strong,nonatomic) NSMutableArray *arrayContact;

///最近联系人/联系人
///区分不同的view from
@property(strong,nonatomic)NSString *typeContact;

@end
