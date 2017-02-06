//
//  SearchResultViewController.h
//  Wechat_XW
//
//  Created by 大家保 on 2017/1/12.
//  Copyright © 2017年 大家保. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PPPersonModel;

@protocol SearchResultSelectedDelegate <NSObject>

//搜索结果的点击事件
-(void)selectPerson:(PPPersonModel *)model;

@end

@interface SearchResultViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchResultsUpdating>

@property(nonatomic,weak)id<SearchResultSelectedDelegate> delegate;

//搜索匹配得到的数据
-(void)updateAddressBookData:(NSArray *) AddressBookDataArray;


@end
