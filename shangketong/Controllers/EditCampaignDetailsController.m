//
//  EditCampaignDetailsController.m
//  shangketong
//
//  Created by sungoin-zjp on 15-9-7.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "EditCampaignDetailsController.h"
#import "CampaignDetailItem.h"

@interface EditCampaignDetailsController ()

@end

@implementation EditCampaignDetailsController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = TABLEVIEW_BG_COLOR;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(saveEdit)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 生成表单
-(void)creatXLFrom{
    XLFormDescriptor *form = [XLFormDescriptor formDescriptor];
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    
    section = [XLFormSectionDescriptor formSection];
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];
    [form addFormSection:section];
    [form addFormSection:section];
    
    
    ///遍历
    if ([self.dicDetails objectForKey:@"columns"] && [[self.dicDetails objectForKey:@"columns"] count] > 0 ) {
        section = [XLFormSectionDescriptor formSectionWithTitle:@"基本信息"];
        [self.form addFormSection:section];
        
        for (NSDictionary *itemOri in self.dicDetails[@"columns"]) {
            
            NSString *valueStr = @"";
            
            CampaignDetailItem *item = [CampaignDetailItem initWithDictionary:itemOri];

        }
    }
    
}

#pragma mark - 保存收藏
-(void)saveEdit{
    
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
