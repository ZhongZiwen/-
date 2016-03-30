//
//  SKTPickerView.m
//  DemoMapViewPOI
//
//  Created by sungoin-zjp on 15-5-11.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#define SKTPickerViewHeight 250
#define SKTPickerViewWidth [UIScreen mainScreen].bounds.size.width



#import "SKTPickerView.h"
#import "CommonConstant.h"
#import "CommonFuntion.h"


@implementation SKTPickerViewItem
@end

@implementation SKTPickerView

- (instancetype)initWithContent:(NSArray *)content
                           data:(NSString *)data byType:(NSString *)type{
    self = [super init];
    if (self) {
         _items = [[NSMutableArray alloc] init];
        _contentType = type;
        _arrayPcikerview = content;
        _showData = data;
        [self buildViews];
    }
    return self;
}

-(void)buildViews{
    self.userInteractionEnabled = YES;
    self.frame = CGRectMake(0, kScreen_Height, SKTPickerViewWidth, SKTPickerViewHeight);
    self.backgroundColor = [UIColor clearColor];

    ///日期选择器
    if ([_contentType isEqualToString:DATE_PICKERVIEW]) {
        _datePickView = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, 40, SKTPickerViewWidth, SKTPickerViewHeight-40)];
        _datePickView.backgroundColor = [UIColor whiteColor];
        
        NSLog(@"_showData:%@",_showData);
        
        NSDateFormatter* formate=[[NSDateFormatter alloc]init];
        [formate setDateFormat:@"yyyy-MM-dd HH:mm"];
//        [formate setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
//        [formate dateFromString:_showData];
        
//        [CommonFunc stringToDate:_showData Format:@"yyyy-MM-dd HH:mm"];
        _datePickView.date = [formate dateFromString:_showData];
//        _datePickView.minimumDate = [CommonFuntion stringToDate:_showData Format:DATE_FORMAT_yyyyMMddHHmm];
//        _datePickView.minimumDate = [NSDate date];
        _datePickView.minimumDate = nil;
        _datePickView.maximumDate = nil;
        [_datePickView addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_datePickView];
        //        _datePickView.minimumDate = [self getOneDate:0 month:-6 day:0];
        //        _datePickView.maximumDate = [NSDate date];
    }else if ([_contentType isEqualToString:PICKERVIEW]) {
        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, SKTPickerViewWidth, SKTPickerViewHeight-10)];
        _pickerView.backgroundColor = [UIColor whiteColor];

        _pickerView.dataSource = self;
        _pickerView.delegate = self;
         [self addSubview:_pickerView];
        
        [_pickerView selectRow:[self getIndexOfSelect] inComponent:0 animated:YES];
    }
}

-(void)willMoveToSuperview:(UIView *)newSuperview
{
    [self addButtonItem];
    [self setNeedsDisplay];
    [self setNeedsLayout];
}

///添加头部按钮  完成、上一个、下一个
- (void)addButtonItem {
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SKTPickerViewWidth, 1)];
    lineView.backgroundColor = [UIColor colorWithHexString:@"c3c3c3"];
    UIView *viewTopBg = [[UIView alloc] initWithFrame:CGRectMake(0, 1, SKTPickerViewWidth, 39)];
    viewTopBg.backgroundColor = [UIColor whiteColor];

    
    [_items enumerateObjectsUsingBlock:^(SKTPickerViewItem *item, NSUInteger idx, BOOL *stop) {
        
        if ( Button_OK == item.type) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            button.translatesAutoresizingMaskIntoConstraints = NO;
            button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(20, 5, 60, 30);
            [button setTitle:@"完成" forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont boldSystemFontOfSize:button.titleLabel.font.pointSize];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            button.tag = 11000+ idx;
            [button addTarget:self
                       action:@selector(okTouched:)forControlEvents:UIControlEventTouchUpInside];
            [viewTopBg addSubview:button];
        }else if (Button_PRE == item.type) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            button.translatesAutoresizingMaskIntoConstraints = NO;
            button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(kScreen_Width-60*2-20*2, 5, 60, 30);
            [button setTitle:@"上一个" forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont boldSystemFontOfSize:button.titleLabel.font.pointSize];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            button.tag = 11000+ idx;
            [button addTarget:self
                       action:@selector(okTouched:)forControlEvents:UIControlEventTouchUpInside];
          //  [viewTopBg addSubview:button];
        }else if (Button_NEXT == item.type) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            button.translatesAutoresizingMaskIntoConstraints = NO;
            button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(kScreen_Width-60-20, 5, 60, 30);
            [button setTitle:@"下一个" forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont boldSystemFontOfSize:button.titleLabel.font.pointSize];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            button.tag = 11000+ idx;
            [button addTarget:self
                       action:@selector(okTouched:)forControlEvents:UIControlEventTouchUpInside];
          //  [viewTopBg addSubview:button];
        }
        [self addSubview:lineView];
        [self addSubview:viewTopBg];
        
    }];
}

- (void)addButton:(ButtonType)type handler:(SKTPickerViewHandler)handler{
    SKTPickerViewItem *item = [[SKTPickerViewItem alloc] init];
    item.action = handler;
    item.type = type;
    item.selectDate = @"";
    [_items addObject:item];
    item.tag = [_items indexOfObject:item];
}

- (void)okTouched:(UIButton*)button{
    SKTPickerViewItem *item = _items[button.tag-11000];
    if (item.action) {
        item.action(item);
    }
    [self dismiss];
}

- (void)show:(UIView *)spview {
    [UIView animateWithDuration:0.4 animations:^{
    } completion:^(BOOL finished) {
    }];
    
    [spview addSubview:self];
    [self showAnimation];
}

- (void)dismiss {
    [self hideAnimation];
}

- (void)showAnimation {
    
    [UIView animateWithDuration:0.4 animations:^{
        self.frame = CGRectMake(0, kScreen_Height-SKTPickerViewHeight, SKTPickerViewWidth, SKTPickerViewHeight);
    } completion:^(BOOL finished) {
        
    }];
    
//    [self ViewAnimation:self willHidden:NO];
    
    
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    [UIView beginAnimations:nil context:context];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//    [UIView setAnimationDuration:0.6];//动画时间长度，单位秒，浮点数
//    [self exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
//    self.frame = CGRectMake(0, kScreen_Height-SKTPickerViewHeight, SKTPickerViewWidth, SKTPickerViewHeight);
//    
//    [UIView setAnimationDelegate:self];
//    [UIView setAnimationDidStopSelector:@selector(animationFinished)];
//    [UIView commitAnimations];
}

-(void)animationFinished{
    NSLog(@"动画结束!");
}

- (void)hideAnimation{
    [UIView animateWithDuration:0.4 animations:^{
        self.frame = CGRectMake(0, kScreen_Height, SKTPickerViewWidth, SKTPickerViewHeight);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

///
-(void)dateChanged:(id)sender{
    NSDate *date= [(UIDatePicker *)sender date];
    NSLog(@"dateChanged dateString:%@",[CommonFuntion dateToString:date Format:DATE_FORMAT_yyyyMMddHHmm]);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectedDate:)]) {
        [self.delegate selectedDate:(NSString *)[CommonFuntion dateToString:date Format:DATE_FORMAT_yyyyMMddHHmm]];
    }
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
    NSString *strSelected=[_arrayPcikerview objectAtIndex:row];
    NSLog(@"pickerView strSelected:%@",strSelected);
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectedData:)]) {
        [self.delegate selectedData:(NSString *)strSelected];
    }
}


///获取当前选中的下标
-(NSInteger)getIndexOfSelect{
    NSInteger index = 0;
    
    NSInteger count = 0;
    if (_arrayPcikerview) {
        count = [_arrayPcikerview count];
    }
    BOOL flag = FALSE;
    for (int i=0; !flag && i<count; i++) {
        if ([_showData isEqualToString:[_arrayPcikerview objectAtIndex:i]]) {
            index = i;
            flag = TRUE;
        }
    }
    return index;
}
@end
