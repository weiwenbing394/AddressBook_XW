//
//  SearchResultViewController.m
//  Wechat_XW
//
//  Created by 大家保 on 2017/1/12.
//  Copyright © 2017年 大家保. All rights reserved.
//

#import "SearchResultViewController.h"
#import "PPPersonModel.h"
#define kScreenWidth    [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight    [[UIScreen mainScreen] bounds].size.height

@interface SearchResultViewController (){
    UITableView *table;
    NSMutableArray *dataSource;
    UILabel *footerLabel;
}

@end

@implementation SearchResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    dataSource = [[NSMutableArray alloc]init];
    table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) style:UITableViewStylePlain];
    table.showsVerticalScrollIndicator = NO;
    table.bouncesZoom = NO;
    table.delegate = self;
    table.dataSource = self;
    table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:table];
    //tableFooterView
    footerLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, table.frame.size.width, 40)];
    footerLabel.textAlignment = NSTextAlignmentCenter;
    footerLabel.textColor = [UIColor lightGrayColor];
    if (dataSource.count==0) {
        footerLabel.text = @"无结果";
        table.tableFooterView = footerLabel;
    }else{
        footerLabel.text = @"";
    }
}

#pragma mark tableviewdelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *reuseIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    }
    if(dataSource.count>0){
        PPPersonModel *people = [dataSource objectAtIndex:indexPath.row];
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
    }else{
        if (dataSource.count==0) {
            footerLabel.text = @"无结果";
            table.tableFooterView = footerLabel;
        }else{
            footerLabel.text = @"";
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

//更新数据
-(void)updateAddressBookData:(NSArray *)AddressBookDataArray{
    [dataSource removeAllObjects];
    [dataSource addObjectsFromArray:AddressBookDataArray];
    [table reloadData];
    if (dataSource.count==0) {
        footerLabel.text = @"无结果";
        table.tableFooterView = footerLabel;
    }else{
        footerLabel.text = @"";
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self dismissViewControllerAnimated:YES completion:^{
        PPPersonModel *people = [dataSource objectAtIndex:indexPath.row];
        if (self.delegate&&[self.delegate respondsToSelector:@selector(selectPerson:)]) {
            [self.delegate selectPerson:people];
        }
    }];
}


#pragma mark - UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
