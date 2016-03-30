//
//  LLCenterYYYYMMPickerView.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-9-15.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "LLCenterYYYYMMPickerView.h"
#import "LLCenterUtility.h"
#import "CommonFunc.h"

@interface LLCenterYYYYMMPickerView (){
    NSString *timeForamt;
}
@end

@implementation LLCenterYYYYMMPickerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithMaxYear:(NSNumber*) maximumYear andMinYear:(NSNumber*) minimumYear andTitle:(NSString *)headTitle  andData:(NSArray *)data andType:(NSInteger)type{
    self = [super init];
    if(self){
        self.frame = CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, DEVICE_BOUNDS_HEIGHT);
        self.backgroundColor = RGBACOLOR(160, 160, 160, 0);
        
         menuView = [[UIView alloc] initWithFrame:CGRectMake(0, DEVICE_BOUNDS_HEIGHT, DEVICE_BOUNDS_WIDTH, 250)];
        menuView.backgroundColor = [UIColor whiteColor];
        
        if (headTitle && headTitle.length > 0) {
            UILabel *lableHeadTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, 40)];
            lableHeadTitle.backgroundColor = [UIColor whiteColor];
            lableHeadTitle.font = [UIFont systemFontOfSize:17.0];
            lableHeadTitle.textColor = COLOR_LIGHT_BLUE;
            lableHeadTitle.textAlignment = NSTextAlignmentCenter;
            lableHeadTitle.text = headTitle;
            [menuView addSubview:lableHeadTitle];
        }
        
        UIButton *btnSave = [UIButton buttonWithType:UIButtonTypeCustom];
        btnSave.frame = CGRectMake(DEVICE_BOUNDS_WIDTH-80, 0, 80, 40);
        [btnSave setTitle:@"确定" forState:UIControlStateNormal];
        [btnSave setTitleColor:COLOR_LIGHT_BLUE forState:UIControlStateNormal];
        btnSave.titleLabel.font = [UIFont systemFontOfSize:17.0];
        [btnSave addTarget:self action:@selector(saveEvent) forControlEvents:UIControlEventTouchUpInside];
        [menuView addSubview:btnSave];
        
        ///年-月
        if (type == 1) {
            _datePickView = [[SRMonthPicker alloc]initWithFrame:CGRectMake(40, 40, DEVICE_BOUNDS_WIDTH-80, 250)];
            _datePickView.backgroundColor = [UIColor whiteColor];
            _datePickView.monthPickerDelegate = self;
            // Some options to play around with
            _datePickView.maximumYear = maximumYear;
            _datePickView.minimumYear = minimumYear;
            _datePickView.yearFirst = YES;
            //        _datePickView.contentMode = UIViewContentModeRight;
            [menuView addSubview:_datePickView];
        }else if (type == 2) {
            _arrayPcikerview = data;
            ///年
            _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, DEVICE_BOUNDS_WIDTH, 250)];
            _pickerView.backgroundColor = [UIColor whiteColor];
            
            _pickerView.dataSource = self;
            _pickerView.delegate = self;
            [self addSubview:_pickerView];
            
            [_pickerView selectRow:0 inComponent:0 animated:YES];
            [menuView addSubview:_pickerView];
        }
        
        [self addSubview:menuView];
        [self animeData];
    }
    return self;
}


-(void)animeData{
    //self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedCancel)];
    [self addGestureRecognizer:tapGesture];
    tapGesture.delegate = self;
    [UIView animateWithDuration:.25 animations:^{
        self.backgroundColor = RGBACOLOR(160, 160, 160, .4);
        [UIView animateWithDuration:.25 animations:^{
            [menuView setFrame:CGRectMake(menuView.frame.origin.x, DEVICE_BOUNDS_HEIGHT-menuView.frame.size.height, menuView.frame.size.width, menuView.frame.size.height)];
        }];
    } completion:^(BOOL finished) {
        
    }];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if([touch.view isKindOfClass:[self class]]){
        return YES;
    }
    return NO;
}

-(void)tappedCancel{
    [UIView animateWithDuration:.25 animations:^{
        [menuView setFrame:CGRectMake(0, DEVICE_BOUNDS_HEIGHT,DEVICE_BOUNDS_WIDTH, 0)];
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

///底部按钮事件
-(void)eventOfFootBtn:(id)sender{
    [self tappedCancel];
}

- (void)showInView:(UIViewController *)Sview
{
    if(Sview==nil){
        [[UIApplication sharedApplication].delegate.window.rootViewController.view addSubview:self];
    }else{
        //[view addSubview:self];
        [Sview.view addSubview:self];
    }
}


#pragma mark - 多选保存操作
-(void)saveEvent{
    [self tappedCancel];
    if (self.selectedDateBlock) {
        self.selectedDateBlock(curSelectDate);
    }
}


- (void)monthPickerWillChangeDate:(SRMonthPicker *)monthPicker
{
}

- (void)monthPickerDidChangeDate:(SRMonthPicker *)monthPicker
{
    // All this GCD stuff is here so that the label change on -[self monthPickerWillChangeDate] will be visible
    dispatch_queue_t delayQueue = dispatch_queue_create("com.simonrice.SRMonthPickerExample.DelayQueue", 0);
    
    dispatch_async(delayQueue, ^{
        // Wait 1 second
//        sleep(1);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            curSelectDate=[self formatDate:_datePickView.date];
        });
    });
    
}



- (NSString*)formatDate:(NSDate *)date
{
    // A convenience method that formats the date in Month-Year format
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM";
    return [formatter stringFromDate:date];
}



#pragma mark pickerview function
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
/*return row number*/
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (_arrayPcikerview) {
        return [_arrayPcikerview count];
    }
    return 0;
}

/*return component row str*/
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [_arrayPcikerview objectAtIndex:row];
}

/*choose com is component,row's function*/
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // NSLog(@"font %@ is selected.",row);
    curSelectDate = [_arrayPcikerview objectAtIndex:row];
    NSLog(@"pickerView curSelectDate:%@",curSelectDate);
}


///获取当前选中的下标
-(NSInteger)getIndexOfSelect{
    NSInteger index = 0;
    NSInteger count = 0;
    if (_arrayPcikerview) {
        count = [_arrayPcikerview count];
    }
    if (count > 0) {
        index = count -1;
    }
    return index;
}


@end
