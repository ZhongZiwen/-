//
//  XLFScheduleTypeViewController.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/10.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XLFormRowDescriptor;

@interface XLFScheduleTypeViewController : UITableViewController

@property (nonatomic, strong) XLFormRowDescriptor *rowDescriptor;

- (id)initWithStyle:(UITableViewStyle)style andTitleHeaderSection:(NSString*)titleHeaderSection andTitleFooterSection:(NSString*)titleFooterSection;
@end
