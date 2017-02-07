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

- (NSInteger)add:(NSInteger)num{
    if (num>1) {
        NSLog(@"%ld",num);
        return num*[self add:(num-1)];
    }
    return num;
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
    return cell;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
