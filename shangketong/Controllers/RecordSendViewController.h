//
//  RecordSendViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/26.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Record;

@interface RecordSendViewController : UIViewController

@property (strong, nonatomic) Record *curRecord;
@property (assign, nonatomic) BOOL isQuickSignIn;
@property (copy, nonatomic) void(^sendNextRecord)(Record *nextRecord);
@end
