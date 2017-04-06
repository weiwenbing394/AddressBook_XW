//
//  XW_AddressManager.h
//  DaJiaBaoMall
//
//  Created by 大家保 on 2017/4/5.
//  Copyright © 2017年 大家保. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XWPersonModel.h"
/**
 *  操作成功block
 */
typedef void (^SuccessBlock) ();
/**
 *  操作失败block
 */
typedef void (^FaildBlock) ();


@interface XW_AddressManager : NSObject

/**
 *  批量添加通讯录
 */
+ (void)addPersonArray:(NSMutableArray<XWPersonModel *> *)personArray SuccessBlock:(SuccessBlock )successBlock FaildBlcok:(FaildBlock) failBlock;


/**
 *  批量删除通讯录
 */
+ (void)deletePersonArray:(NSMutableArray<XWPersonModel *> *)personArray SuccessBlock:(SuccessBlock )successBlock FaildBlcok:(FaildBlock) failBlock;


@end
