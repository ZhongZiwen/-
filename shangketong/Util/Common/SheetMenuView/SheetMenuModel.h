//
//  SheetMenuModel.h
//  shangketong
//
//  Created by sungoin-zjp on 15-6-9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SheetMenuModel : NSObject
@property(nonatomic,strong) NSString *icon;
@property(nonatomic,strong) NSString *icon_selected;
@property(nonatomic,strong) NSString *iconLeft;
@property(nonatomic,strong) NSString *iconLeft_selected;
@property(nonatomic,strong) NSString *iconRight;
@property(nonatomic,strong) NSString *iconRight_selected;
@property(nonatomic,strong) NSString *title;
@property(nonatomic,strong) NSString *btnNum;
@end
