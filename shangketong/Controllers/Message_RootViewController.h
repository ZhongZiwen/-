//
//  Message_RootViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/4/22.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface Message_RootViewController : BaseViewController

@property (nonatomic, strong) NSString *selectGroupId; //被选中的讨论组id

- (void)getConversationList;
@end
