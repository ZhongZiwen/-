//
//  XLFTaskDetailForFilesCell.m
//  shangketong
//
//  Created by 蒋 on 15/9/11.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "XLFTaskDetailForFilesCell.h"
#import "UIView+Common.h"
#import "KnowledgeFileDetailsViewController.h"

NSString *const XLFormRowDescriptorTypeFiles = @"XLFormRowDescriptorTypeFiles";
#define K_View_Width 30
#define K_Bettown_Two_View_Width 15

@interface XLFTaskDetailForFilesCell ()

@property (nonatomic, strong) UIImageView *file_ImgView;
@property (nonatomic, strong) UILabel *file_NameLabel;
@property (nonatomic, strong) UILabel *file_SizeLabel;

@end

@implementation XLFTaskDetailForFilesCell

- (UIImageView *)file_ImgView {
    if (!_file_ImgView) {
        _file_ImgView = [[UIImageView alloc] initWithFrame:CGRectMake(K_Bettown_Two_View_Width, 5, K_View_Width, 34)];
        [_file_ImgView setCenterY:[XLFTaskDetailForFilesCell formDescriptorCellHeightForRowDescriptor:self.rowDescriptor] / 2.0];
    }
    return _file_ImgView;
}
- (UILabel *)file_NameLabel {
    if (!_file_NameLabel) {
        _file_NameLabel = [[UILabel alloc] initWithFrame:CGRectMake(K_View_Width + K_Bettown_Two_View_Width * 2, 5,kScreen_Width - K_View_Width + K_Bettown_Two_View_Width * 3, 20)];
       // [_file_NameLabel setCenterY:[XLFTaskDetailForFilesCell formDescriptorCellHeightForRowDescriptor:self.rowDescriptor] / 2.0];
        _file_NameLabel.font = [UIFont systemFontOfSize:12];
        _file_NameLabel.textColor = [UIColor blackColor];
        _file_NameLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _file_NameLabel;
}
- (UILabel *)file_SizeLabel {
    if (!_file_SizeLabel) {
        _file_SizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(K_View_Width + K_Bettown_Two_View_Width * 2, 25, kScreen_Width - K_View_Width + K_Bettown_Two_View_Width * 3, 20)];
       // [_file_SizeLabel setCenterY:[XLFTaskDetailForFilesCell formDescriptorCellHeightForRowDescriptor:self.rowDescriptor] / 2.0];
        _file_SizeLabel.font = [UIFont systemFontOfSize:12];
        _file_SizeLabel.textColor = [UIColor blackColor];
        _file_SizeLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _file_SizeLabel;
}
+ (CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor {
    return 50.f;
}
+ (void)load {
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:[XLFTaskDetailForFilesCell class] forKey:XLFormRowDescriptorTypeFiles];
}

- (void)configure {
    [super configure];
    
    [self.contentView addSubview:self.file_ImgView];
    [self.contentView addSubview:self.file_NameLabel];
    [self.contentView addSubview:self.file_SizeLabel];

}

- (void)update {
    [super update];
    
    NSDictionary *dict = (NSDictionary*)self.rowDescriptor.value;
    _file_ImgView.image = [UIImage imageNamed:[dict safeObjectForKey:@"image"]];
    _file_NameLabel.text = [dict safeObjectForKey:@"text"];
    //            double newSize = size / 1024.0;  [NSString stringWithFormat:@"%.2fkb", newSize
    NSInteger oldSize = [[dict safeObjectForKey:@"detail"] integerValue];
    double newSize = oldSize / 1024.0;
    _file_SizeLabel.text = [NSString stringWithFormat:@"%.2fkb", newSize];;
}
- (void)formDescriptorCellDidSelectedWithFormController:(XLFormViewController *)controller {
    [self.formViewController.tableView selectRowAtIndexPath:nil animated:YES scrollPosition:UITableViewScrollPositionNone];
    KnowledgeFileDetailsViewController *knowController = [[KnowledgeFileDetailsViewController alloc] init];
    knowController.isNeedRightNavBtn = YES;
    knowController.detailsOld = [self changeKeyAndValueOfOldDcit];
    knowController.viewFrom = @"other";
    [self.formViewController.navigationController pushViewController:knowController animated:YES];
}
//重组字典key - value
- (NSDictionary *)changeKeyAndValueOfOldDcit {
    NSDictionary *oldDict = (NSDictionary *)self.rowDescriptor.value;
    NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithCapacity:0];
    [newDict setObject:[oldDict objectForKey:@"url"] forKey:@"url"];
    [newDict setObject:[oldDict objectForKey:@"text"] forKey:@"name"];
    [newDict setObject:[oldDict objectForKey:@"detail"] forKey:@"size"];
    return newDict;
}
@end
