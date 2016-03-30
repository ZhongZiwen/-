//
//  EmotionItem.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/25.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "EmotionItem.h"

@interface EmotionItem ()

@property (nonatomic, weak) UIButton *emotionItem;
@property (nonatomic, copy) NSString *emotionName;
@end

@implementation EmotionItem

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = self.bounds;
        [button addTarget:self action:@selector(emotionItemPress) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        self.emotionItem = button;
    }
    return self;
}

- (void)emotionItemPress {
    if (self.emotionItemBlock) {
        self.emotionItemBlock(self.emotionName);
    }
}

- (void)configWithImage:(UIImage *)image andName:(NSString *)nameStr {
    [_emotionItem setImage:image forState:UIControlStateNormal];
    _emotionName = nameStr;
}

@end
