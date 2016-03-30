//
//  MeInfoViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/4/22.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "WorkGroupRecordViewController.h"

typedef NS_ENUM(NSInteger, InfoType) {
    InfoTypeMyself,
    InfoTypeOthers
};

@interface InfoViewController : BaseViewController
@property (nonatomic, assign) InfoType infoTypeOfUser;
@property (nonatomic, assign) NSInteger userId;
@end
