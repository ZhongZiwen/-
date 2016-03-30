//
//  MsgRootMoreResultsController.h
//  shangketong
//
//  Created by 蒋 on 15/11/20.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MsgRootMoreResultsController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableViewResult;
@property (nonatomic, strong) NSArray *resultArray;
@property (nonatomic, strong) NSString *titelSting;
@property (nonatomic, copy) void(^BlackGroupIdBlock)(NSString *groupId);
@end
