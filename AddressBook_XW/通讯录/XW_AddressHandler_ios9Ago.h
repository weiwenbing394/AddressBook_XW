//
//  XW_AddressHandler_ios9Ago.h
//  DaJiaBaoMall
//
//  Created by 大家保 on 2017/4/5.
//  Copyright © 2017年 大家保. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XWPersonModel.h"

@interface XW_AddressHandler_ios9Ago : NSObject

//单例
+ (XW_AddressHandler_ios9Ago *)Handler_ios9Ago;

//添加通讯录
- (void)addPersonArray:(NSMutableArray<XWPersonModel *> *)personModelArray SuccessBlock:(void (^) (void)) success FaildBlock:(void(^)(void))faild;

//删除通讯录
- (void)deletePersonArray:(NSMutableArray<XWPersonModel *> *)personModelArray SuccessBlock:(void (^) (void)) success FaildBlock:(void(^)(void))faild;


@end
