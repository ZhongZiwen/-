//
//  ApprovalSelectViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/8/26.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ApprovalSelectViewController : UIViewController

@property (nonatomic, strong) NSArray *approvalReveiwer;
@property (nonatomic, copy) void(^valueBlock) (NSDictionary *dict);
@end
