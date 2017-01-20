//
//  PPGetAddressBook.h
//  PPGetAddressBook
//
//  Created by AndyPang on 16/8/17.
//  Copyright © 2016年 AndyPang. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "PPAddressBookHandle.h"
#import "PPPersonModel.h"

/**
 *  获取原始顺序的所有联系人的Block
 */
typedef void(^AddressBookArrayBlock)(NSArray<PPPersonModel *> *addressBookArray);

/**
 *  获取按A~Z顺序排列的所有联系人的Block
 *
 *  @param addressBookDict 装有所有联系人的字典->每个字典key对应装有多个联系人模型的数组->每个模型里面包含着用户的相关信息.
 *  @param nameKeys   联系人姓名的大写首字母的数组
 */
typedef void(^AddressBookDictBlock)(NSDictionary<NSString *,NSArray *> *addressBookDict,NSArray *nameKeys);



@interface PPGetAddressBook : NSObject

/**
 *  获取原始顺序排列的所有联系人
 *
 *  @param addressBookArray 装着原始顺序的联系人字典Block回调
 */
+ (void)getOriginalAddressBook:(AddressBookArrayBlock)addressBookArray FaildBlock:(void(^)(void))faild;

/**
 *  获取按A~Z顺序排列的所有联系人
 *
 *  @param addressBookInfo 装着A~Z排序的联系人字典Block回调
 * 
 */
+ (void)getOrderAddressBook:(AddressBookDictBlock)addressBookInfo FaildBlock:(void(^)(void))faild;


@end
