//
//  AddressBookUI.m
//  AddressBook_XW
//
//  Created by 大家保 on 2017/1/20.
//  Copyright © 2017年 大家保. All rights reserved.
//

#import "AddressBookUI.h"
#import "PPGetAddressBook.h"

@interface AddressBookUI ()

@property (nonatomic,strong) NSArray *BookArray;

@end

@implementation AddressBookUI

- (void)awakeFromNib{
    [super awakeFromNib];
    self.tableView.tableFooterView=[UIView new];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [PPGetAddressBook getOriginalAddressBook:^(NSArray<PPPersonModel *> *addressBookArray) {
        _BookArray=addressBookArray;
        [self.tableView reloadData];
    } FaildBlock:^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请在iPhone的“设置-隐私-通讯录”选项中，允许PPAddressBook访问您的通讯录" delegate:nil cancelButtonTitle:@"知道了"otherButtonTitles:nil];
        [alert show];
    }];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _BookArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *reuseIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    }
    PPPersonModel *people = [_BookArray objectAtIndex:indexPath.row];
    cell.imageView.image = people.headerImage ? people.headerImage : [UIImage imageNamed:@"defult"];
    cell.imageView.layer.cornerRadius = 60/2;
    cell.imageView.clipsToBounds = YES;
    cell.textLabel.text = people.name;
    cell.detailTextLabel.text=people.mobileArray[0];
    return cell;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
