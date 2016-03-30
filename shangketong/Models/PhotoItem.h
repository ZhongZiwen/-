//
//  PhotoItem.h
//  shangketong
//
//  Created by sungoin-zbs on 16/2/26.
//  Copyright © 2016年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhotoItem : NSObject

@property (copy, nonatomic) NSString *url;
@property (copy, nonatomic) NSString *minUrl;
@property (strong, nonatomic) UIImageView *srcImageView;
@end
