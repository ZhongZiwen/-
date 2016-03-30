//
//  ReleasePrivacyListController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ReleasePrivacyListController.h"
#import "ReleasePrivacyListCell.h"
#import "ReleasePrivacyItem.h"
#import "CommonConstant.h"
#import "CommonRequstFuntion.h"
#import "AFNHttp.h"
#import "ChineseToPinyin.h"
#import "ReleaseViewController.h"

#define kCellIdentifier @"ReleasePrivacyListCell"

@interface ReleasePrivacyListController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *sourceArray;
@property (nonatomic, strong) NSMutableArray *allGroupArr;
@property (nonatomic, strong) NSMutableArray *groupKeyArr; //存储所有的key（排好序的）
@property (nonatomic, strong) NSMutableDictionary *addPhoneContact; //存数组装好的分组
@end

@implementation ReleasePrivacyListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = kView_BG_Color;
    
    /*
    NSArray *array = @[@"departments", @"groups"];
    NSString *fileName = array[_indexRow - 1];
    
    NSData *data = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:@"json"]];
    NSDictionary *tempDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    _sourceArray = [[NSMutableArray alloc] initWithArray:tempDict[@"body"][fileName]];
     */
    _allGroupArr = [NSMutableArray arrayWithCapacity:0];
    _groupKeyArr = [NSMutableArray arrayWithCapacity:0];
    _addPhoneContact = [NSMutableDictionary dictionaryWithCapacity:0];
    [self.view addSubview:self.tableView];
    [self getCurData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 获取部门、群组数据
-(void)getCurData{
    _sourceArray = [[NSMutableArray alloc] init];
    ///部门
    if (_indexRow == 1) {
        [self getDepartmentData];
    }else if(_indexRow == 2){
        ///群组
        [self getGroupData];
    }
}

-(void)getDepartmentData{

    [self getDepartmentsOrGroupDataFromService:@"department"];
    
}

-(void)getGroupData{

    ///从服务器获取群组数据
    [self getDepartmentsOrGroupDataFromService:@"group"];
}




#pragma mark - UITableView_M

#pragma mark -- tableView Delegate And DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_groupKeyArr count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[_addPhoneContact objectForKey:_groupKeyArr[section]] count];
}

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
    return _groupKeyArr[section];
}

- (NSArray*)sectionIndexTitlesForTableView:(UITableView*)tableView {
    return _groupKeyArr;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ReleasePrivacyListCell cellHeight];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ReleasePrivacyListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    NSString *imageStr = @"";
    
   if (_indexRow == 1) {
       imageStr = @"depart_icon.png";
    }else{
        imageStr = @"Department_default.png";
    }
    NSString *name = [_addPhoneContact[_groupKeyArr[indexPath.section]][indexPath.row] safeObjectForKey:@"name"];
    NSInteger count = [[_addPhoneContact[_groupKeyArr[indexPath.section]][indexPath.row] safeObjectForKey:@"count"] integerValue];
    
    [cell configWithImageName:imageStr andTitle:name andCount:count];
    
    if ([_privacyItem.privacyString isEqualToString:name]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    _privacyItem.indexRow = _indexRow;
    NSString *privacyString = [_addPhoneContact[_groupKeyArr[indexPath.section]][indexPath.row] safeObjectForKey:@"name"];
    _privacyItem.privacyString = privacyString;
    
    long long selectedId = [[_addPhoneContact[_groupKeyArr[indexPath.section]][indexPath.row] safeObjectForKey:@"id"] integerValue];
    
    _privacyItem.selectedId = selectedId;
    
    NSLog(@"privacyString:%@  %lli",privacyString,selectedId);
    
    if (self.selectRowBlock) {
        self.selectRowBlock(_privacyItem);
    }
    //这里老代码有个问题。 下标为2的controller对应的不一定都是ReleaseViewController。
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[ReleaseViewController class]]) {
            [self.navigationController popToViewController:controller animated:YES];
        }
    }
//    [self.navigationController popToViewController:self.navigationController.viewControllers[2] animated:YES];
}

#pragma mark - setters and getters
- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[ReleasePrivacyListCell class] forCellReuseIdentifier:kCellIdentifier];
        UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
        [_tableView setTableFooterView:v];
    }
    return _tableView;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


-(void)getDepartmentsOrGroupDataFromService:(NSString *)dataType{
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    NSString *url = @"";
    
    ///部门  蒋晓飞--这个地方获取部门
    if ([dataType isEqualToString:@"department"]) {//ADDRESS_BOOK_DEPARAMENT_AND_ALL_CHILD_ACTION
        url = [NSString stringWithFormat:@"%@%@",MOBILE_SERVER_IP_OA,ADDRESS_BOOK_DEPARAMENT_AND_ALL_CHILD_ACTION];
    }else{
        ///群组
        url = [NSString stringWithFormat:@"%@%@",MOBILE_SERVER_IP_OA,ADDRESS_BOOK_GROUP_ACTION];
    }
    
    // 发起请求
    [AFNHttp post:url params:params success:^(id responseObj) {
        //字典转模型
        NSLog(@"部门/群组 responseObj:%@",responseObj);
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            
                NSArray *resultArray;
                ///部门
                if ([dataType isEqualToString:@"department"]) {
                    if ([responseObj objectForKey:@"departments"]) {
                        resultArray = [responseObj  objectForKey:@"departments"];
                        
                        [self initDataByResult:resultArray];
                    }
                }else{
                    ///群组
                    if ([responseObj objectForKey:@"groups"]) {
                        resultArray = [responseObj  objectForKey:@"groups"];
                        
                        [self initDataByResult:resultArray];
                    }
                }
           
        }else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getDepartmentsOrGroupDataFromService:dataType];
            };
            [comRequest loginInBackground];
        }
        
    } failure:^(NSError *error) {
        NSLog(@"error:%@",error);
        
    }];
}


///根据服务器返回数据做处理
-(void)initDataByResult:(NSArray *)resultArray{
    [_sourceArray removeAllObjects];
    if (resultArray) {
        [_sourceArray addObjectsFromArray:resultArray];
    }
    
    [self getValueForKey];
    [self getValueForPhoneContact];
    [self.tableView reloadData];
}

#pragma mark -- get Key (获取索引)
- (void)getValueForKey{
    NSString *pinyinStr = @"";
    NSMutableArray *keyArr = [NSMutableArray arrayWithCapacity:0];
    //①先对字典进行遍历获取到分组对应的拼音，得到首字母
    //②对首字母进行重复剔除
    //③对剔除后的首字母进行排序
    
    NSInteger count = 0;
    NSDictionary *contactDic;
    if (_sourceArray) {
        count = [_sourceArray count];
    }
    
    for (int i=0; i<count; i++) {
        contactDic = [_sourceArray objectAtIndex:i];
        if ([contactDic objectForKey:@"pinyin"]) {
            pinyinStr = [contactDic safeObjectForKey:@"pinyin"];
            if ([pinyinStr isEqualToString:@""]) {
                NSString *name = @"";
                if ([contactDic objectForKey:@"name"]) {
                    name = [contactDic safeObjectForKey:@"name"];
                }
                pinyinStr = [ChineseToPinyin pinyinFromChiniseString:name];
            }
            
            
        }else{
            NSString *name = @"";
            if ([contactDic objectForKey:@"name"]) {
                name = [contactDic safeObjectForKey:@"name"];
            }
            pinyinStr = [ChineseToPinyin pinyinFromChiniseString:name];
        }
        
        NSLog(@"pinyinStr:%@",pinyinStr);
        NSString *key = @"";
        if (pinyinStr != nil && pinyinStr.length > 0) {
            unichar firstLetter = [pinyinStr characterAtIndex:0];
            // 首字符是字母
            if(isalpha(firstLetter)){
                key = [[pinyinStr substringToIndex:1] uppercaseString];
                
            }else
            {
                // 归于其他分类
                key = @"#";
                pinyinStr = @"#";
            }
        }else{
            key = @"#";
            pinyinStr = @"#";
        }
        if (![keyArr containsObject:key]) {
            [keyArr addObject:key];
        }
        
        ///修改本地数据
        NSMutableDictionary *mutableItemNew = [NSMutableDictionary dictionaryWithDictionary:contactDic];
        [mutableItemNew setObject:pinyinStr forKey:@"pinyin"];
        //修改数据
        [_sourceArray setObject: mutableItemNew atIndexedSubscript:i];
    }
    
    NSArray *resultkArrSort = [keyArr sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    
    [keyArr removeAllObjects];
    [keyArr addObjectsFromArray:resultkArrSort];
    
    if (keyArr != nil && [keyArr count] > 0) {
        // 将#放到最后
        if ([keyArr containsObject:@"#"]) {
            [keyArr removeObject:@"#"];
            [keyArr addObject:@"#"];
        }
    }
    
    NSLog(@"keyArr:%@",keyArr);
    
    //    NSSet *set = [NSSet setWithArray:keyArr];
    //    NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:nil ascending:YES]];
    //    _groupKeyArr = [NSMutableArray arrayWithArray:[set sortedArrayUsingDescriptors:sortDesc]];
    //    NSLog(@"arr--- : %@, %@", _groupKeyArr, set);
    _groupKeyArr = [NSMutableArray arrayWithArray:keyArr];
}
#pragma  mark -- get phoneContact
//获取排好序的部门或者组
- (void)getValueForPhoneContact {
    NSString *nameStr = @"";
    for (NSString *str in _groupKeyArr) {
        for (NSDictionary *phoneContactDic in _sourceArray) {
            if ([phoneContactDic objectForKey:@"pinyin"]) {
                nameStr =  [[[phoneContactDic safeObjectForKey:@"pinyin"] substringToIndex:1] capitalizedString];
                if ([nameStr isEqualToString:str]) {
                    [_allGroupArr addObject:phoneContactDic];
                }
            }
        }
        [_addPhoneContact setValue:[_allGroupArr mutableCopy] forKey:str];
        [_allGroupArr removeAllObjects];
    }
    NSLog(@"_addPhoneContact: %@", _addPhoneContact);
}

@end
