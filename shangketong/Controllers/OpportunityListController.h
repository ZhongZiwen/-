//
//  OpportunityListController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/11/16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, OpportunityListFromType) {
    OpportunityListFromTypeCustomer,
    OpportunityListFromTypeContact
};

@interface OpportunityListController : UIViewController

@property (copy, nonatomic) NSString *requestListPath;
@property (copy, nonatomic) NSString *requestInitPath;
@property (copy, nonatomic) NSString *requestSavePath;
@property (strong, nonatomic) NSNumber *customerId;
@property (strong, nonatomic) NSNumber *contactId;
@property (assign, nonatomic) OpportunityListFromType fromType;
@property (copy, nonatomic) void(^refreshBlock)(void);

- (void)deleteAndRefreshDataSource;
@end
