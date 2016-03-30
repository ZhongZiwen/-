//
//  ContactListViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/11/16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ContactListFromType) {
    ContactListFromTypeCustomer,
    ContactListFromTypeOpportunity
};

@interface ContactListViewController : UIViewController

@property (copy, nonatomic) NSString *requestListPath;
@property (copy, nonatomic) NSString *requestInitPath;
@property (copy, nonatomic) NSString *requestScanfPath;
@property (copy, nonatomic) NSString *requestSavePath;
@property (strong, nonatomic) NSNumber *customerId;
@property (assign, nonatomic) ContactListFromType fromType;
@property (copy, nonatomic) void(^refreshBlock)(void);

- (void)deleteAndRefreshDataSource;
@end
