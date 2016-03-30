//
//  OpportunityStageChanceController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/11/15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpportunityStage;

@interface OpportunityStageChanceController : UIViewController

@property (strong, nonatomic) OpportunityStage *currentStage;
@property (strong, nonatomic) NSMutableArray *sourceArray;
@property (copy, nonatomic) void(^refreshBlock)(OpportunityStage*);
@end
