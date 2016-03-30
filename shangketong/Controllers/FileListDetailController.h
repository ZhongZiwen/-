//
//  FileListDetailController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/11/4.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "BaseViewController.h"

@class Directory;

@interface FileListDetailController : BaseViewController

@property (strong, nonatomic) Directory *directory;
@property (assign, nonatomic) BOOL isShowRightBarButton;
@end
