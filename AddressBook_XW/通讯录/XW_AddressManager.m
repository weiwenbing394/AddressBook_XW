//
//  XW_AddressManager.m
//  DaJiaBaoMall
//
//  Created by 大家保 on 2017/4/5.
//  Copyright © 2017年 大家保. All rights reserved.
//

#import "XW_AddressManager.h"

#ifdef __IPHONE_9_0
#import <Contacts/Contacts.h>
#import "XW_AddressHandler_ios9Later.h"
#endif

#import <AddressBook/AddressBook.h>
#import "XW_AddressHandler_ios9Ago.h"

#import "XWPersonModel.h"
#define IOS9_LATER ([[UIDevice currentDevice] systemVersion].floatValue >= 9.0 ? YES : NO )

@implementation XW_AddressManager

/**
 *  批量添加通讯录
 */
+ (void)addPersonArray:(NSMutableArray<XWPersonModel *> *)personArray SuccessBlock:(SuccessBlock )successBlock FaildBlcok:(FaildBlock) failBlock{
    // 将耗时操作放到子线程
    dispatch_queue_t queue = dispatch_queue_create("addressBook.add", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        if (IOS9_LATER) {
            [[XW_AddressHandler_ios9Later Handler_ios9Later] addPersonArray:personArray SuccessBlock:successBlock FaildBlock:failBlock];
        }else{
            [[XW_AddressHandler_ios9Ago Handler_ios9Ago] addPersonArray:personArray SuccessBlock:successBlock FaildBlock:failBlock];
        }
    });
};

/**
 *  批量删除通讯录
 */
+ (void)deletePersonArray:(NSMutableArray<XWPersonModel *> *)personArray SuccessBlock:(SuccessBlock )successBlock FaildBlcok:(FaildBlock) failBlock{
    // 将耗时操作放到子线程
    dispatch_queue_t queue = dispatch_queue_create("addressBook.delete", DISPATCH_QUEUE_SERIAL);
    //ios8权限需在主线程执行，故放主线程执行
    dispatch_async(queue, ^{
        if (IOS9_LATER) {
            [[XW_AddressHandler_ios9Later Handler_ios9Later] deletePersonArray:personArray SuccessBlock:successBlock FaildBlock:failBlock];
        }else{
            [[XW_AddressHandler_ios9Ago Handler_ios9Ago] deletePersonArray:personArray SuccessBlock:successBlock FaildBlock:failBlock];
        }
    });
};

@end
