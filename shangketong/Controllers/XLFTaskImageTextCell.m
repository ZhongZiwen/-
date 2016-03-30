//
//  XLFTaskImageTextCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/8/12.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "XLFTaskImageTextCell.h"
#import "NSString+Common.h"
#import "UIView+Common.h"
#import "KnowledgeFileDetailsViewController.h"
#import "PlanViewController.h"
#import "AFNHttp.h"
#import "MBProgressHUD.h"
#import "EditTextForDetailController.h"

NSString *const XLFormRowDescriptorTypeTaskImageText = @"XLFormRowDescriptorTypeTaskImageText";

#define kFontSize_Content 16

@interface XLFTaskImageTextCell ()

@property (nonatomic, strong) UIImageView *markImageView;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIButton *checkButton;
@property (nonatomic, strong) UIButton *editButton;
@end

@implementation XLFTaskImageTextCell

+ (void)load {
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:[XLFTaskImageTextCell class] forKey:XLFormRowDescriptorTypeTaskImageText];
}

- (void)configure {
    [super configure];
    
    [self.contentView addSubview:self.markImageView];
    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.checkButton];
    [self.contentView addSubview:self.editButton];
}

- (void)update {
    [super update];
    
    NSDictionary *dict = (NSDictionary*)self.rowDescriptor.value;
    
    _markImageView.image = [UIImage imageNamed:[dict objectForKey:@"image"]];
    if ([dict objectForKey:@""]) {
        
    }
    _contentLabel.text = [dict objectForKey:@"content"];
    
    if (dict && [[dict allKeys] containsObject:@"flag"] && [dict objectForKey:@"flag"]) {
        if ([[dict objectForKey:@"flag"] isEqualToString:@"0"]) {
            _markImageView.userInteractionEnabled = YES;
        } else {
            _markImageView.userInteractionEnabled = NO;
        }
    }
    if ([[dict objectForKey:@"isEdit"] isEqualToString:@"1"]) {
        if ([[dict objectForKey:@"isEditOrDate"] isEqualToString:@"1"]) {
            _checkButton.hidden = YES;
            _editButton.hidden = NO;
        } else {
            _checkButton.hidden = NO;
            _editButton.hidden = YES;
        }
    } else {
        _checkButton.hidden = YES;
        _editButton.hidden = YES;
    }
    
}

+ (CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor {
    return 50.f;
}

#pragma mark - event response
- (void)checkButtonPress {
    NSDictionary *dict = (NSDictionary*)self.rowDescriptor.value;
    PlanViewController *controller = [[PlanViewController alloc] init];
    controller.flagFromWhereIntoPlan = 0;
    controller.dateStr = [dict safeObjectForKey:@"date"];
    [self.formViewController.navigationController pushViewController:controller animated:YES];
}
- (void)editTestForTaskName {
    __weak typeof(self) weak_self = self;
    NSDictionary *dict = (NSDictionary*)weak_self.rowDescriptor.value;
    EditTextForDetailController *controller = [[EditTextForDetailController alloc] init];
    controller.title = @"编辑";
    controller.textStr = [dict objectForKey:@"content"];
    NSString *imgNameStr = [dict safeObjectForKey:@"image"];
    NSString *uid = [dict safeObjectForKey:@"taskID"];
    NSString *isEnabledFlag = [dict safeObjectForKey:@"flag"];
    NSString *taskType = [dict safeObjectForKey:@"type"];
    NSString *isAllEdit = [dict safeObjectForKey:@"isEdit"];
    NSString *editOrDateStr = [dict safeObjectForKey:@"isEditOrDate"];
    controller.backTextViewValveBlock = ^(NSString *string) {
        XLFormRowDescriptor *rowDescriptor = [weak_self.formViewController.form formRowWithTag:@"title"];
        rowDescriptor.value = @{@"image" : imgNameStr,
                                @"content" : string,
                                @"taskID" : uid,
                                @"flag" : isEnabledFlag,
                                @"type" : taskType,
                                @"isEdit" : isAllEdit,
                                @"isEditOrDate" : editOrDateStr};
        [weak_self.formViewController updateFormRow:rowDescriptor];
    };
    [weak_self.formViewController.navigationController pushViewController:controller animated:YES];

}
- (void)editButtonPress {
    BOOL hasAction = self.rowDescriptor.action.formBlock || self.rowDescriptor.action.formSelector;
    if (hasAction) {
        if (self.rowDescriptor.action.formBlock) {
            self.rowDescriptor.action.formBlock(self.rowDescriptor);
        }
    }
}

#pragma mark - setters and getters
- (UIImageView*)markImageView {
    if (!_markImageView) {
        _markImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 0, 20, 20)];
        [_markImageView setCenterY:[XLFTaskImageTextCell formDescriptorCellHeightForRowDescriptor:self.rowDescriptor] / 2.0];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editButtonPress)];
        [_markImageView addGestureRecognizer:tap];
    }
    return _markImageView;
}
- (UILabel*)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(15 + 20 + 10, 0, kScreen_Width - 15 - 20 - 10 - 64, 30)];
        [_contentLabel setCenterY:[XLFTaskImageTextCell formDescriptorCellHeightForRowDescriptor:self.rowDescriptor] / 2.0];
        _contentLabel.font = [UIFont systemFontOfSize:kFontSize_Content];
        _contentLabel.textColor = [UIColor blackColor];
        _contentLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _contentLabel;
}

- (UIButton*)checkButton {
    if (!_checkButton) {
        _checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _checkButton.frame = CGRectMake(kScreen_Width - 64, 0, 64, [XLFTaskImageTextCell formDescriptorCellHeightForRowDescriptor:self.rowDescriptor]);
        _checkButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_checkButton setTitle:@"查看日历" forState:UIControlStateNormal];
        [_checkButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_checkButton addTarget:self action:@selector(checkButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _checkButton;
}

- (UIButton*)editButton {
    if (!_editButton) {
        _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _editButton.frame = CGRectMake(kScreen_Width - 64, 0, 64, [XLFTaskImageTextCell formDescriptorCellHeightForRowDescriptor:self.rowDescriptor]);
        _editButton.backgroundColor = [UIColor whiteColor];
        [_editButton setImage:[UIImage imageNamed:@"edit_doc"] forState:UIControlStateNormal];
        [_editButton addTarget:self action:@selector(editTestForTaskName) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editButton;
}

- (void)formDescriptorCellDidSelectedWithFormController:(XLFormViewController *)controller {
    [self.formViewController.tableView selectRowAtIndexPath:nil animated:YES scrollPosition:UITableViewScrollPositionNone];
    XLFormRowDescriptor *rowDescroptor;
    
    if ([rowDescroptor.tag isEqualToString:@"files"]) {
        KnowledgeFileDetailsViewController *knowController = [[KnowledgeFileDetailsViewController alloc] init];
        knowController.isNeedRightNavBtn = YES;
        [self.formViewController.navigationController pushViewController:knowController animated:YES];
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
