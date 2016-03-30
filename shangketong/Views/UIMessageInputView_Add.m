//
//  UIMessageInputView_Add.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/17.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "UIMessageInputView_Add.h"


@implementation UIMessageInputView_Add

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"0xf8f8f8"];
        
        UIButton *cameraItem = [self buttonWithImageName:@"keyboard_add_camera" andTitle:@"拍照" andIndex:0];
        UIButton *photoItem = [self buttonWithImageName:@"keyboard_add_photo" andTitle:@"相册" andIndex:1];
        [self addSubview:cameraItem];
        [self addSubview:photoItem];
    }
    return self;
}

- (UIButton*)buttonWithImageName:(NSString*)imageName andTitle:(NSString*)titleStr andIndex:(NSInteger)index {
    CGFloat itemWidth = (kScreen_Width - 5*20)/4;
    CGFloat itemHeight = itemWidth + 20;
    CGFloat leftX = 20, topY = 20, space = 20;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(leftX + (space + itemWidth) * (index % 4), topY + (space + itemHeight) * (index / 4), itemWidth, itemHeight);
    [button setImageEdgeInsets:UIEdgeInsetsMake(-10, 0, 10, 0)];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    button.tag = 200 + index;
    [button addTarget:self action:@selector(addItemButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, itemHeight-20, itemWidth, 20)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor colorWithHexString:@"0x666666"];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = titleStr;
    [button addSubview:label];
    
    return button;
}

- (void)addItemButtonPress:(UIButton*)sender {
    NSInteger index = sender.tag - 200;
    if (self.addButtonClickBlock) {
        self.addButtonClickBlock(index);
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
