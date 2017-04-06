//
//  XWPersonModel.h
//  DaJiaBaoMall
//
//  Created by 大家保 on 2017/4/5.
//  Copyright © 2017年 大家保. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XWPersonModel : NSObject
/** 联系人姓名*/
@property (nonatomic, copy) NSString *name;
/** 联系人电话*/
@property (nonatomic, strong) NSString *phone;
/** 联系人的性别*/
@property (nonatomic,copy) NSString *sex;
/** 联系人是否选中*/
@property (nonatomic,assign) BOOL checked;

@end
