//
//  CallListFilterPeopleCell.m
//  lianluozhongxin
//
//  Created by Vescky on 14-6-23.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import "CallListFilterPeopleCell.h"

@interface CallListFilterPeopleCell ()

@end

@implementation CallListFilterPeopleCell

- (void)setCellDataInfo:(NSDictionary*)cInfo {
    
    NSString *userName;
    if ([[cInfo objectForKey:@"USERNAME"] isKindOfClass:NSClassFromString(@"NSString")]) {
        userName = [NSString stringWithFormat:@"%@",[cInfo safeObjectForKey:@"USERNAME"]];
    }
    else {
        userName = @"未知";
    }
    
    NSString *jobNumber;
    if ([[cInfo objectForKey:@"USERCODE"] isKindOfClass:NSClassFromString(@"NSString")]) {
        jobNumber = [NSString stringWithFormat:@"%@",[cInfo safeObjectForKey:@"USERCODE"]];
    }
    else {
        jobNumber = @"未知";
    }
    
    NSString *phoneNumber;
    if ([cInfo objectForKey:@"BIND_PHONENO"]) {
        if ([[cInfo objectForKey:@"BIND_PHONENO"] isKindOfClass:NSClassFromString(@"NSString")]) {
            phoneNumber = [NSString stringWithFormat:@"%@",[cInfo safeObjectForKey:@"BIND_PHONENO"]];
        }
    }
    else {
        if ([[cInfo objectForKey:@"BIND_PHONENO"] isKindOfClass:NSClassFromString(@"NSString")]) {
            phoneNumber = [NSString stringWithFormat:@"%@",[cInfo safeObjectForKey:@"BIND_PHONENO"]];
        }
    }
    
    if ([cInfo objectForKey:@"all"]) {
        jobNumber = @"";
        phoneNumber = @"";
    }
    
    labelName.text = userName;
    labelWorkNo.text = jobNumber;
    labelPhoneNum.text = phoneNumber;
    
    
    
//    if (![cInfo objectForKey:@"USERCODE"]) {
//        labelWorkNo.hidden = YES;
//    }
//    else {
//        labelWorkNo.text = [cInfo objectForKey:@"USERCODE"];
//    }
//    
//    if (![cInfo objectForKey:@"CALLEE_NO"]) {
//        labelPhoneNum.hidden = YES;
//    }
//    else {
//        labelPhoneNum.text = [cInfo objectForKey:@"CALLEE_NO"];
//    }
    
}


@end
