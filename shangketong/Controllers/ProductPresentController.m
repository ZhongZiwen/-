//
//  ProductPresentController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ProductPresentController.h"
#import "Product.h"

@interface ProductPresentController ()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UITextField *countField;

@end

@implementation ProductPresentController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor iOS7lightBlueColor];
    self.view.layer.cornerRadius = 8.0f;

    [self customDismissButton];
    [self customConfireButton];
    [self customTitleLabel];
    [self customCountField];
    [self customStepCounter];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _titleLabel.text = [NSString stringWithFormat:@"修改[%@]数量", _item.name];
    _countField.text = [NSString stringWithFormat:@"%@", _item.number];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_countField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - event response
- (void)dismissButtonPress {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)confireButtonPress {
    if (self.refreshBlock) {
        self.refreshBlock();
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)minueButtonPress {
    NSInteger temp = ([_item.number integerValue] - 1) > 0 ? [_item.number integerValue] - 1 : 0;
    _item.number = @(temp);
    _item.totalPrivce = @([_item.number integerValue] * [_item.unitPrice floatValue]);
    _countField.text = [NSString stringWithFormat:@"%@", _item.number];
}

- (void)addButtonPress {
    _item.number = @([_item.number integerValue] + 1);
    _item.totalPrivce = @([_item.number integerValue] * [_item.unitPrice floatValue]);
    _countField.text = [NSString stringWithFormat:@"%@", _item.number];
}

- (void)textFieldDidChange:(UITextField *)textField {
    if (textField.text) {
        _item.number = @([textField.text integerValue]);
    }else {
        _item.number = @0;
    }
    
    _item.totalPrivce = @([_item.number integerValue] * [_item.unitPrice floatValue]);
}

#pragma mark - private method
- (void)customDismissButton {
    UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
    dismissButton.translatesAutoresizingMaskIntoConstraints = NO;
    [dismissButton setTitle:@"取 消" forState:UIControlStateNormal];
    [dismissButton addTarget:self action:@selector(dismissButtonPress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:dismissButton];
    
    NSArray *dismissArray = @[[NSLayoutConstraint constraintWithItem:dismissButton
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.view
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:0.5f
                                                            constant:0.f],
                              [NSLayoutConstraint constraintWithItem:dismissButton
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                          multiplier:1.f
                                                            constant:44.f],
                              [NSLayoutConstraint constraintWithItem:dismissButton
                                                           attribute:NSLayoutAttributeLeft
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.view
                                                           attribute:NSLayoutAttributeLeft
                                                          multiplier:1.f
                                                            constant:0.f],
                              [NSLayoutConstraint constraintWithItem:dismissButton
                                                           attribute:NSLayoutAttributeBottom
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.view
                                                           attribute:NSLayoutAttributeBottom
                                                          multiplier:1.f
                                                            constant:0.f]];
    
    [self.view addConstraints:dismissArray];
}

- (void)customConfireButton {
    UIButton *confireButton = [UIButton buttonWithType:UIButtonTypeCustom];
    confireButton.translatesAutoresizingMaskIntoConstraints = NO;
    [confireButton setTitle:@"确 定" forState:UIControlStateNormal];
    [confireButton addTarget:self action:@selector(confireButtonPress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:confireButton];
    
    NSArray *confireArray = @[[NSLayoutConstraint constraintWithItem:confireButton
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.view
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:0.5f
                                                            constant:0.f],
                              [NSLayoutConstraint constraintWithItem:confireButton
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                          multiplier:1.f
                                                            constant:44.f],
                              [NSLayoutConstraint constraintWithItem:confireButton
                                                           attribute:NSLayoutAttributeRight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.view
                                                           attribute:NSLayoutAttributeRight
                                                          multiplier:1.f
                                                            constant:0.f],
                              [NSLayoutConstraint constraintWithItem:confireButton
                                                           attribute:NSLayoutAttributeBottom
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.view
                                                           attribute:NSLayoutAttributeBottom
                                                          multiplier:1.f
                                                            constant:0.f]];
    
    [self.view addConstraints:confireArray];
}

- (void)customTitleLabel {
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.font = [UIFont systemFontOfSize:18];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.text = @"修改数量";
    [self.view addSubview:_titleLabel];
    
    NSArray *titleArray = @[[NSLayoutConstraint constraintWithItem:_titleLabel
                                                           attribute:NSLayoutAttributeWidth
                                                    relatedBy:NSLayoutRelationEqual
                                                              toItem:self.view
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:1.f
                                                            constant:-30.f],
                              [NSLayoutConstraint constraintWithItem:_titleLabel
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                          multiplier:1.f
                                                            constant:44.f],
                              [NSLayoutConstraint constraintWithItem:_titleLabel
                                                           attribute:NSLayoutAttributeCenterX
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.view
                                                           attribute:NSLayoutAttributeCenterX
                                                          multiplier:1.f
                                                            constant:0.f]];
    
    [self.view addConstraints:titleArray];
}

- (void)customCountField {
    _countField = [[UITextField alloc] init];
    _countField.translatesAutoresizingMaskIntoConstraints = NO;
    _countField.backgroundColor = [UIColor whiteColor];
    _countField.font = [UIFont systemFontOfSize:14];
    _countField.placeholder = @"输入数量";
    _countField.layer.borderWidth = 0.5;
    _countField.layer.borderColor = [UIColor iOS7lightGrayColor].CGColor;
    _countField.keyboardType = UIKeyboardTypeNumberPad;
    [_countField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:_countField];
    
    NSArray *countArray = @[[NSLayoutConstraint constraintWithItem:_countField
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                          multiplier:1.f
                                                            constant:64.f],
                              [NSLayoutConstraint constraintWithItem:_countField
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                          multiplier:1.f
                                                            constant:30.f],
                              [NSLayoutConstraint constraintWithItem:_countField
                                                           attribute:NSLayoutAttributeCenterX
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.view
                                                           attribute:NSLayoutAttributeCenterX
                                                          multiplier:1.f
                                                            constant:0.f],
                              [NSLayoutConstraint constraintWithItem:_countField
                                                           attribute:NSLayoutAttributeCenterY
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.view
                                                           attribute:NSLayoutAttributeCenterY
                                                          multiplier:1.f
                                                            constant:0.f]];
    
    [self.view addConstraints:countArray];
}

- (void)customStepCounter {
    
    UIImage *addImage = [UIImage imageNamed:@"addBtn"];
    UIImage *minueImage = [UIImage imageNamed:@"minueBtn"];
    
    UIButton *minueButton = [UIButton buttonWithType:UIButtonTypeCustom];
    minueButton.translatesAutoresizingMaskIntoConstraints = NO;
    minueButton.backgroundColor = [UIColor whiteColor];
    [minueButton setImage:minueImage forState:UIControlStateNormal];
    [minueButton addTarget:self action:@selector(minueButtonPress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:minueButton];
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.translatesAutoresizingMaskIntoConstraints = NO;
    addButton.backgroundColor = [UIColor whiteColor];
    [addButton setImage:addImage forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addButtonPress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addButton];
    
    NSArray *stepArray = @[[NSLayoutConstraint constraintWithItem:minueButton
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:_countField
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:1.f
                                                          constant:0.f],
                            [NSLayoutConstraint constraintWithItem:minueButton
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:_countField
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:1.f
                                                          constant:0.f],
                            [NSLayoutConstraint constraintWithItem:minueButton
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:_countField
                                                         attribute:NSLayoutAttributeLeft
                                                        multiplier:1.f
                                                          constant:-10.f],
                            [NSLayoutConstraint constraintWithItem:minueButton
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:_countField
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.f
                                                          constant:0.f],
                           [NSLayoutConstraint constraintWithItem:addButton
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_countField
                                                        attribute:NSLayoutAttributeHeight
                                                       multiplier:1.f
                                                         constant:0.f],
                           [NSLayoutConstraint constraintWithItem:addButton
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_countField
                                                        attribute:NSLayoutAttributeHeight
                                                       multiplier:1.f
                                                         constant:0.f],
                           [NSLayoutConstraint constraintWithItem:addButton
                                                        attribute:NSLayoutAttributeLeft
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_countField
                                                        attribute:NSLayoutAttributeRight
                                                       multiplier:1.f
                                                         constant:10.f],
                           [NSLayoutConstraint constraintWithItem:addButton
                                                        attribute:NSLayoutAttributeCenterY
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_countField
                                                        attribute:NSLayoutAttributeCenterY
                                                       multiplier:1.f
                                                         constant:0.f]];
    
    [self.view addConstraints:stepArray];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
