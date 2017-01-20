//
//  PPDataHandle.h
//  PPAddressBook
//
//  Created by AndyPang on 16/8/17.
//  Copyright © 2016年 AndyPang. All rights reserved.
//


#import <Foundation/Foundation.h>
#ifdef __IPHONE_9_0
#import <Contacts/Contacts.h>
#endif
#import <AddressBook/AddressBook.h>
#import "PPPersonModel.h"
#import "PPSingleton.h"
#define IOS9_LATER ([[UIDevice currentDevice] systemVersion].floatValue > 9.0 ? YES : NO )

/** 所有联系人的数组信息*/
typedef void(^PPPersonModelArrayBlock)(NSMutableArray *modelArray);

@interface PPAddressBookHandle : NSObject

PPSingletonH(AddressBookHandle)

/**
 *  返回所有联系人模型
 *
 */
- (void)getAddressBookDataSource:(PPPersonModelArrayBlock)personModelArray FaildBlock:(void(^)(void))faild;

@end
