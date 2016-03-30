//
//  FileDownloadView.h
//  shangketong
//
//  Created by sungoin-zbs on 15/11/4.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileManager.h"

@class Directory;

@interface FileDownloadView : UIView

@property (strong, nonatomic) Directory *directory;
@property (copy, nonatomic) void(^completeBlock)(void);

- (void)reloadData;
@end
