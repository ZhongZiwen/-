//
//  InputAccessoryView.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/4.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "InputAccessoryView.h"

@implementation InputAccessoryView

+ (InputAccessoryView*)sharedAccessoryView {
    static dispatch_once_t onceToken;
    static InputAccessoryView *accessoryView = nil;
    dispatch_once(&onceToken, ^{
        accessoryView = [[InputAccessoryView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 44)];
    });
    return accessoryView;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        self.backgroundColor = [UIColor whiteColor];
        
        UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:self.bounds];
        
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(completeAction)];
        
        UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        
        UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:@[@"上一个", @"下一个"]];
        segment.frame = CGRectMake(0, 0, 120, 34);
        segment.momentary = YES;    //设置在点击后是否恢复原样
        [segment addTarget:self action:@selector(segmentedAction:) forControlEvents:UIControlEventValueChanged];
        UIBarButtonItem *segmentItem = [[UIBarButtonItem alloc] initWithCustomView:segment];
        
        toolBar.items = @[item, spaceItem, segmentItem];
        [self addSubview:toolBar];
    }
    return self;
}

#pragma mark - event response
- (void)completeAction {
    NSLog(@"complete");
}

- (void)segmentedAction:(UISegmentedControl*)seg {
    NSLog(@"%d", seg.selectedSegmentIndex);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
