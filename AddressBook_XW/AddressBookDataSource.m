//
//  AddressBookDataSource.m
//  AddressBook_XW
//
//  Created by 大家保 on 2017/1/20.
//  Copyright © 2017年 大家保. All rights reserved.
//

#import "AddressBookDataSource.h"
#import "PPGetAddressBook.h"
#import "SearchResultViewController.h"
#import "PinYin4Objc.h"
#import "AddressCell.h"

@interface AddressBookDataSource ()<UISearchBarDelegate,SearchResultSelectedDelegate,UISearchControllerDelegate>{
    //搜索controller
    UISearchController *searchController;
    //搜索结果Controller
    SearchResultViewController *resultController;
    //符合搜索条件的联系人集合
    NSMutableArray *updateArray;
}
//所有联系人数据
@property (nonatomic, copy) NSDictionary *contactPeopleDict;
//所有联系人索引
@property (nonatomic, copy) NSArray *keys;
//选中的联系人数组
@property (nonatomic, strong) NSMutableArray *insertPeopleArray;
//所有的联系人数组
@property (nonatomic, strong) NSMutableArray *allPeopleArray;
//转换成汉字拼音的规则
@property(nonatomic,strong) HanyuPinyinOutputFormat *formatter;

@end

@implementation AddressBookDataSource

- (void)awakeFromNib{
    [super awakeFromNib];
    self.tableView.tableFooterView=[UIView new];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *allButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 44)];
    [allButton setTitle:@"全选" forState:UIControlStateNormal];
    [allButton setTitle:@"全不选" forState:UIControlStateSelected];
    [allButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    allButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [allButton addTarget:self action:@selector(selectAll:) forControlEvents:UIControlEventTouchUpInside];
    [allButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    UIButton *completeButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 64, 44)];
    [completeButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    NSMutableAttributedString *attribute=[[NSMutableAttributedString alloc]initWithString:@"完成(0)"];
    [attribute addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(3, 1)];
    [completeButton setAttributedTitle:attribute forState:UIControlStateNormal];
    [completeButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    completeButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [completeButton addTarget:self action:@selector(completed:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc]initWithCustomView:completeButton],[[UIBarButtonItem alloc]initWithCustomView:allButton]];
    updateArray=[NSMutableArray array];
    
    //获取按联系人姓名首字拼音A~Z排序(已经对姓名的第二个字做了处理)
    [PPGetAddressBook getOrderAddressBook:^(NSDictionary<NSString *,NSArray *> *addressBookDict, NSArray *nameKeys) {
        //装着所有联系人的字典
        self.contactPeopleDict = addressBookDict;
        //联系人分组按拼音分组的Key值
        self.keys = nameKeys;
        //处于编辑状态
        self.tableView.editing=YES;
        //tableview索引的背景颜色和字体颜色的设置
        self.tableView.sectionIndexColor=[UIColor darkGrayColor];
        self.tableView.sectionIndexBackgroundColor=[UIColor clearColor];
        //tableview的tintcolor
        self.tableView.tintColor=[UIColor lightGrayColor];
        //tableheaderView
        self.tableView.tableHeaderView=[self getSearchBarView];
        [searchController.view bringSubviewToFront:searchController.searchBar];
        [self.tableView reloadData];
    } FaildBlock:^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请在iPhone的“设置-隐私-通讯录”选项中，允许PPAddressBook访问您的通讯录" delegate:nil cancelButtonTitle:@"知道了"otherButtonTitles:nil];
        [alert show];
    }];
}

//搜索框
- (UISearchBar *)getSearchBarView{
    self.definesPresentationContext = YES;
    // 将searchBar的cancel按钮改成中文的
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitle:@"取消"];
    //搜索结果控制器
    resultController=[[SearchResultViewController alloc]init];
    resultController.delegate=self;
    //搜索控制器
    searchController=[[UISearchController alloc]initWithSearchResultsController:resultController];
    searchController.searchResultsUpdater =resultController;
    searchController.searchBar.placeholder=@"搜索";
    searchController.searchBar.tintColor=[UIColor lightGrayColor];
    searchController.searchBar.delegate=self;
    //设置searchBar的边框颜色，四周的颜色
    searchController.searchBar.barTintColor=[UIColor groupTableViewBackgroundColor];
    UIImageView *view=[[[searchController.searchBar.subviews objectAtIndex:0] subviews] firstObject];
    view.layer.borderColor=[UIColor groupTableViewBackgroundColor].CGColor;
    view.layer.borderWidth=1;
    //解决iOS 8.4中searchBar看不到的bug
    UISearchBar *bar=searchController.searchBar;
    bar.barStyle=UIBarStyleDefault;
    bar.translucent=YES;
    CGRect rect=bar.frame;
    rect.size.height=44;
    bar.frame=rect;
    return bar;
}

//全选|全不选
- (void)selectAll:(UIButton *)btn{
    btn.selected=!btn.selected;
    [self.insertPeopleArray removeAllObjects];
    if (btn.selected) {
        for (int i=0; i<_keys.count; i++) {
            NSString *key=_keys[i];
            for (int j=0; j<[_contactPeopleDict[key] count]; j++) {
                NSIndexPath *indexPath=[NSIndexPath indexPathForRow:j inSection:i];
                [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                PPPersonModel *people = [_contactPeopleDict[key] objectAtIndex:indexPath.row];
                [self.insertPeopleArray addObject:people];
            }
        }
    }else{
        for (int i=0; i<_keys.count; i++) {
            NSString *key=_keys[i];
            for (int j=0; j<[_contactPeopleDict[key] count]; j++) {
                NSIndexPath *indexPath=[NSIndexPath indexPathForRow:j inSection:i];
                [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
            }
        }
    }
    [self setcount];
}

//完成
- (void)completed:(UIButton *)btn{
    NSLog(@"选中的联系人个数是：%ld",self.insertPeopleArray.count);
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - TableViewDatasouce/TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _keys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSString *key = _keys[section];
    return [_contactPeopleDict[key] count];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return _keys[section];
}

//右侧的索引
- (NSArray*)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return _keys;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *reuseIdentifier = @"cell";
    AddressCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell){
        cell = [[AddressCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    }
    NSString *key = _keys[indexPath.section];
    PPPersonModel *people = [_contactPeopleDict[key] objectAtIndex:indexPath.row];
    cell.imageView.image = people.headerImage ? people.headerImage : [UIImage imageNamed:@"defult-1.jpg"];
    cell.imageView.layer.cornerRadius = 40/2;
    cell.imageView.clipsToBounds = YES;
    
    //iOS UITableViewCell 的 imageView大小更改
    CGSize itemSize = CGSizeMake(40, 40);
    UIGraphicsBeginImageContext(itemSize);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    cell.textLabel.text = people.name;
    cell.detailTextLabel.text=people.mobileArray[0];
    NSLog(@"地址：%@,邮箱：%@,工作：%@,电话：%@",people.addressArray[0],people.emailArray[0],people.job,people.mobileArray[0]);
    return cell;
}




-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *key = _keys[indexPath.section];
    PPPersonModel *people = [_contactPeopleDict[key] objectAtIndex:indexPath.row];
    [self.insertPeopleArray addObject:people];
    [self setcount];
}


- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *key = _keys[indexPath.section];
    PPPersonModel *people = [_contactPeopleDict[key] objectAtIndex:indexPath.row];
    [self.insertPeopleArray removeObject:people];
    [self setcount];
}

#pragma mark 复选
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

// 多选模式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

//设置选中的数量
- (void)setcount{
    UIBarButtonItem *insertBarButtonItem=self.navigationItem.rightBarButtonItems[0];
    UIButton *insertBarButton=(UIButton *)insertBarButtonItem.customView;
    NSString *count=[NSString stringWithFormat:@"完成(%ld)",self.insertPeopleArray.count];
    NSMutableAttributedString *attribute=[[NSMutableAttributedString alloc]initWithString:count];
    [attribute addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(3, [NSString stringWithFormat:@"%ld",self.insertPeopleArray.count].length)];
    [insertBarButton setAttributedTitle:attribute forState:UIControlStateNormal];
    
    UIBarButtonItem *allBarButtonItem=self.navigationItem.rightBarButtonItems[1];
    UIButton *allButton=(UIButton *)allBarButtonItem.customView;
    allButton.selected=(self.insertPeopleArray.count==self.allPeopleArray.count);
}



#pragma mark SearchResultSelectedDelegate  点击搜索结果的代理方法
-(void)selectPerson:(PPPersonModel *)model{
    searchController.searchBar.text = @"";
    NSString *key=[[[PinyinHelper toHanyuPinyinStringWithNSString:model.name withHanyuPinyinOutputFormat:self.formatter withNSString:@""] uppercaseString] substringToIndex:1];
    if (0<key.length) {
        if ([_keys containsObject:key]) {
          NSInteger sectionIndex=[_keys indexOfObject:key];
          NSArray   *modelArray=_contactPeopleDict[key];
         if ([modelArray containsObject:model]) {
             NSInteger rowIndex=[modelArray indexOfObject:model];
             NSIndexPath *selectIndexPath=[NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
             [self.tableView selectRowAtIndexPath:selectIndexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
             if ([self.insertPeopleArray containsObject:model]==NO) {
                 [self.insertPeopleArray addObject:model];
                 [self setcount];
             }
          }
       }
    }
}

#pragma mark UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchText) {
        [updateArray removeAllObjects];
        if ([PinyinHelper isIncludeChineseInString:searchText]) {// 如果是中文
            for(int i=0;i<self.allPeopleArray.count;i++){
                PPPersonModel *people=self.allPeopleArray[i];
                if ([people.name rangeOfString:searchText].location!=NSNotFound) {
                    [updateArray addObject:people];
                }
            }
        }else{//如果是拼音
            for(int i=0;i<self.allPeopleArray.count;i++){
                PPPersonModel *people=self.allPeopleArray[i];
                NSString *outputPinyin=[[PinyinHelper toHanyuPinyinStringWithNSString:people.name withHanyuPinyinOutputFormat:self.formatter withNSString:@""] lowercaseString];
                if ([outputPinyin rangeOfString:[searchText lowercaseString]].location!=NSNotFound){
                    [updateArray addObject:people];
                }
            }
        }
    }
    [resultController updateAddressBookData:updateArray];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    searchController.searchBar.showsCancelButton = YES;
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar{
    [searchBar resignFirstResponder];
}



#pragma mark 懒加载
- (NSMutableArray *)insertPeopleArray{
    if (!_insertPeopleArray) {
        _insertPeopleArray=[NSMutableArray array];
    }
    return _insertPeopleArray;
}

- (NSMutableArray *)allPeopleArray{
    if (!_allPeopleArray) {
        _allPeopleArray=[NSMutableArray array];
        for (int i=0; i<_keys.count; i++) {
            NSString *key=_keys[i];
            for (int j=0; j<[_contactPeopleDict[key] count]; j++) {
                NSIndexPath *indexPath=[NSIndexPath indexPathForRow:j inSection:i];
                PPPersonModel *people = [_contactPeopleDict[key] objectAtIndex:indexPath.row];
                [_allPeopleArray addObject:people];
            }
        }
    }
    return _allPeopleArray;
}
- (HanyuPinyinOutputFormat *)formatter{
    if (!_formatter) {
        _formatter=[[HanyuPinyinOutputFormat alloc]init];
        _formatter.caseType=CaseTypeLowercase;
        _formatter.vCharType=VCharTypeWithV;
        _formatter.toneType=ToneTypeWithoutTone;
    }
    return _formatter;
}

@end
