//
//  FileListController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/29.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "BaseViewController.h"

@interface FileListController : BaseViewController

@property (copy, nonatomic) NSString *requestPath;
@property (strong ,nonatomic) NSNumber *id;

- (void)refreshDataSource;
- (void)deleteDataSource;
@end
