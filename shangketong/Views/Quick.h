//
//  Quick.h
//  shangketong
//
//  Created by sungoin-zbs on 15/7/13.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Quick : NSObject<NSCoding>

@property (copy, nonatomic) NSString *imageString;
@property (copy, nonatomic) NSString *titleString;
@property (strong, nonatomic) NSNumber *isSelected;
@end
