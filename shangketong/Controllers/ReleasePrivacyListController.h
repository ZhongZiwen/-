//
//  ReleasePrivacyListController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/7/15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ReleasePrivacyItem;

@interface ReleasePrivacyListController : UIViewController

@property (nonatomic, strong) ReleasePrivacyItem *privacyItem;
@property (nonatomic, assign) NSInteger indexRow;
@property (nonatomic, copy) void(^selectRowBlock)(ReleasePrivacyItem*);
@end
