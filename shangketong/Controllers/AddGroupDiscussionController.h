//
//  AddGroupDiscussionController.h
//  shangketong
//
//  Created by 蒋 on 15/10/16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddGroupDiscussionController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableViewGroup;
///上级ID
@property (nonatomic, strong) NSString *parentId;

@end
