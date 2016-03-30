//
//  EmotionPageView.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/25.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "EmotionPageView.h"
#import "EmotionItem.h"

@implementation EmotionPageView

- (instancetype)initWithFrame:(CGRect)frame andEmotionSource:(NSDictionary *)emotionDict andPageIndex:(NSInteger)pageIndex {
    self = [super initWithFrame:frame];
    if (self) {
        
        CGFloat btnWidth = floor(CGRectGetWidth(self.bounds) / 7.0);
        CGFloat btnHeight = floor(CGRectGetHeight(self.bounds) / 3.0);
        
        for (int i = 0; i < 21; i ++) {
            CGRect itemFrame = CGRectMake(btnWidth * (i % 7), btnHeight * (i / 7), btnWidth, btnHeight);
            if (i == 20) {
                UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
                deleteButton.frame = itemFrame;
                [deleteButton setImage:[UIImage imageNamed:@"emotionDeleteButton"] forState:UIControlStateNormal];
                [deleteButton addTarget:self action:@selector(deleteButtonPress) forControlEvents:UIControlEventTouchUpInside];
                [self addSubview:deleteButton];
            }else {

                
                NSString *imageStr = [NSString stringWithFormat:@"e_%d", pageIndex * 20 + i + 1];
                // 获取图片信息
                UIImage *image = [UIImage imageNamed:imageStr];
                NSString *imageName;
                
                for (int index = 0; index < [[emotionDict allKeys] count]; index++) {
                    if ([[emotionDict objectForKey:[[emotionDict allKeys] objectAtIndex:index]] isEqualToString:imageStr]) {
                        imageName = [[emotionDict allKeys] objectAtIndex:index];
                    }
                }
                
//                NSLog(@"imageStr:%@ imageName :%@",imageStr,imageName);
                EmotionItem *item = [[EmotionItem alloc] initWithFrame:itemFrame];
                item.emotionItemBlock = ^(NSString *emotionName) {
                    if (self.useEmotionBlock) {
                        self.useEmotionBlock(emotionName);
                    }
                };
                [item configWithImage:image andName:imageName];
                [self addSubview:item];
            }
        }
    }
    return self;
}

- (void)deleteButtonPress {
    if (self.deleteEmotionBlock) {
        self.deleteEmotionBlock();
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
