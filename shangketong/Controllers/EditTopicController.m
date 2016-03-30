//
//  EditTopicController.m
//  shangketong
//
//  Created by 蒋 on 15/9/16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "EditTopicController.h"
#import "CommonFuntion.h"


@interface EditTopicController ()

@property (strong, nonatomic) UITextField *editTF;

@end

@implementation EditTopicController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"编辑主题";
    
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    
    [self.view addSubview:self.editTF];
    [self setFrameForAllPhone];
    if (_topicTitle.length > 0) {
        NSString *groupName = @"";
        if (_topicTitle.length > 20) {
            groupName = [_topicTitle substringToIndex:20];
        } else {
            groupName = _topicTitle;
        }
        self.editTF.text = groupName;
         _countLabel.text = [NSString stringWithFormat:@"%ld/20", groupName.length];
    }

    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(saveButtonPress)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    // Do any additional setup after loading the view from its nib.
}
- (void)saveButtonPress {
    if (_editTF.text.length > 0) {
        if (_BackGroupTopicBlock) {
            _BackGroupTopicBlock(_editTF.text);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    _editTF.layer.borderColor = [UIColor redColor].CGColor;
    [_editTF becomeFirstResponder];
    
}
- (void)editTextOfGroupTopic:(UITextField *)textField {
    if (textField.text.length <= 20) {
      _countLabel.text = [NSString stringWithFormat:@"%ld/20", textField.text.length];
    } else {
        _editTF.text = [textField.text substringToIndex:20];
    }
}
- (void)setFrameForAllPhone {
    CGFloat vX = kScreen_Width - 320;
    _editTF.frame = [CommonFuntion setViewFrameOffset:_editTF.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    _countLabel.frame = [CommonFuntion setViewFrameOffset:_countLabel.frame byX:vX byY:0 ByWidth:0 byHeight:0];
}
- (UITextField *)editTF {
    if (!_editTF) {
        _editTF = [[UITextField alloc] initWithFrame:CGRectMake(0, 80, kScreen_Width, 40)];
        _editTF.text = _topicTitle;
        _editTF.borderStyle = UITextBorderStyleNone;
        _editTF.backgroundColor = [UIColor whiteColor];
        _editTF.layer.borderColor = [UIColor colorWithRed:220.0f/255 green:220.0f/255 blue:220.0f/255 alpha:1.0f].CGColor;
        _editTF.layer.borderWidth = 0.5;
        _editTF.font = [UIFont systemFontOfSize:13];
        [_editTF addTarget:self action:@selector(editTextOfGroupTopic:) forControlEvents:UIControlEventEditingChanged];
    }
    return _editTF;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
