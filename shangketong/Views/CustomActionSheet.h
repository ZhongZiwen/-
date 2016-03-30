//
//  CustomActionSheet.h
//  shangketong
//
//  Created by sungoin-zbs on 15/7/10.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ActionSheetTypeFrom) {
    ActionSheetTypeFromOther,
    ActionSheetTypeFromActivity,
    ActionSheetTypeFromNewContact,
    ActionSheetTypeFromReason
};

@interface CustomActionSheet : UIView

@property (copy, nonatomic) NSString *title;
@property (strong, nonatomic) NSArray *sourceArray;
@property (assign, nonatomic) ActionSheetTypeFrom actionType;
@property (copy, nonatomic) void(^selectedBlock) (id obj, ActionSheetTypeFrom typeFrom);

- (void)show;
- (void)dismiss;
@end

