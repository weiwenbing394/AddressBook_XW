//
//  XW_AddressHandler_ios9Ago.m
//  DaJiaBaoMall
//
//  Created by 大家保 on 2017/4/5.
//  Copyright © 2017年 大家保. All rights reserved.
//

#import "XW_AddressHandler_ios9Ago.h"
#import <AddressBook/AddressBook.h>
#import <UIKit/UIKit.h>
#define KeyWindow [UIApplication sharedApplication].delegate.window
#define WeakSelf __weak typeof(self) weakSelf = self

@interface XW_AddressHandler_ios9Ago (){
    // 删除数量
    int removeCount;
    //更新数量
    int updateCount;
    //增加数量
    int addCount;
}

@end

@implementation XW_AddressHandler_ios9Ago

//添加通讯录
- (void)addPersonArray:(NSMutableArray<XWPersonModel *> *)personModelArray SuccessBlock:(void (^) (void)) success FaildBlock:(void(^)(void))faild{
        WeakSelf;
        // 1.获取授权状态
        ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
        // 2.如果没有授权,先执行授权
        if (status == kABAuthorizationStatusAuthorized){
            //开始添加
            dispatch_async(dispatch_get_main_queue(), ^{
                //[MBProgressHUD showHUDWithTitle:@"正在导入，请稍后..."];
            });
            [weakSelf addContactToContactList:personModelArray SuccessBlock:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                   // [MBProgressHUD hiddenHUD];
                    if (addCount>0&&updateCount>0) {
                        [weakSelf alertWithMessage:[NSString stringWithFormat:@"本次成功添加%d个联系人,成功更新%d个联系人",addCount,updateCount]];
                    }else if (addCount>0&&updateCount==0){
                        [weakSelf alertWithMessage:[NSString stringWithFormat:@"本次成功添加%d个联系人",addCount]];
                    }else if (addCount==0&&updateCount>0){
                        [weakSelf alertWithMessage:[NSString stringWithFormat:@"本次成功更新%d个联系人",updateCount]];
                    }
                    success?success():nil;
                });
            } FaildBlock:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    //[MBProgressHUD hiddenHUD];
                    [weakSelf alertWithMessage:@"请在iphone的“设置-隐私-通讯录”选项中，允许圈圈访问您的通讯录"];
                    faild?faild():nil;
                });
            }];
        }else{
            [weakSelf requestAuthorizationWithSuccessBlock:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    //[MBProgressHUD showHUDWithTitle:@"正在导入，请稍后..."];
                });
                [weakSelf addContactToContactList:personModelArray SuccessBlock:^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                       // [MBProgressHUD hiddenHUD];
                        if (addCount>0&&updateCount>0) {
                            [weakSelf alertWithMessage:[NSString stringWithFormat:@"本次成功添加%d个联系人,成功更新%d个联系人",addCount,updateCount]];
                        }else if (addCount>0&&updateCount==0){
                            [weakSelf alertWithMessage:[NSString stringWithFormat:@"本次成功添加%d个联系人",addCount]];
                        }else if (addCount==0&&updateCount>0){
                            [weakSelf alertWithMessage:[NSString stringWithFormat:@"本次成功更新%d个联系人",updateCount]];
                        }
                        success?success():nil;
                    });
                } FaildBlock:^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //[MBProgressHUD hiddenHUD];
                        [weakSelf alertWithMessage:@"请在iphone的“设置-隐私-通讯录”选项中，允许圈圈访问您的通讯录"];
                        faild?faild():nil;
                    });
                }];
            } faildBlock:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    //[MBProgressHUD hiddenHUD];
                    [weakSelf alertWithMessage:@"请在iphone的“设置-隐私-通讯录”选项中，允许圈圈访问您的通讯录"];
                    faild?faild():nil;
                });
            }];
        }
};

//删除通讯录
- (void)deletePersonArray:(NSMutableArray<XWPersonModel *> *)personModelArray SuccessBlock:(void (^) (void)) success FaildBlock:(void(^)(void))faild{
    WeakSelf;
    // 1.获取授权状态
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    // 2.如果没有授权,先执行授权
    if (status == kABAuthorizationStatusAuthorized){
        //开始删除
        dispatch_async(dispatch_get_main_queue(), ^{
            //[MBProgressHUD showHUDWithTitle:@"正在清除，请稍后..."];
        });
        [weakSelf deleteContactFromContactList:personModelArray SuccessBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                //[MBProgressHUD hiddenHUD];
                [weakSelf alertWithMessage:[NSString stringWithFormat:@"本次成功删除%d个联系人",removeCount]];
                success?success():nil;
            });
        } FaildBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                //[MBProgressHUD hiddenHUD];
                [weakSelf alertWithMessage:@"请在iphone的“设置-隐私-通讯录”选项中，允许圈圈访问您的通讯录"];
                faild?faild():nil;
            });
        }];
    }else{
        [weakSelf requestAuthorizationWithSuccessBlock:^{
            //开始删除
            dispatch_async(dispatch_get_main_queue(), ^{
                //[MBProgressHUD showHUDWithTitle:@"正在清除，请稍后..."];
            });
            [weakSelf deleteContactFromContactList:personModelArray SuccessBlock:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    //[MBProgressHUD hiddenHUD];
                    [weakSelf alertWithMessage:[NSString stringWithFormat:@"本次成功删除%d个联系人",removeCount]];
                    success?success():nil;
                });
            } FaildBlock:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    //[MBProgressHUD hiddenHUD];
                    [weakSelf alertWithMessage:@"请在iphone的“设置-隐私-通讯录”选项中，允许圈圈访问您的通讯录"];
                    faild?faild():nil;
                });
            }];
        } faildBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                //[MBProgressHUD hiddenHUD];
                [weakSelf alertWithMessage:@"请在iphone的“设置-隐私-通讯录”选项中，允许圈圈访问您的通讯录"];
                faild?faild():nil;
            });
        }];
    }
};


/**
 *  添加联系人数组到通讯录
 */
-(void)addContactToContactList:(NSMutableArray<XWPersonModel *> *)modelArray SuccessBlock:(void (^) (void)) success FaildBlock:(void(^)(void))faild{
    updateCount=0;
    addCount=0;
    for (XWPersonModel *model in modelArray) {
        //首先更新，根据更新是否成功来判断是否要添加的原来就存在
        BOOL success = [self updateAddressBookWithFirstName:(0==model.name.length?@"":model.name) phoneNumber:(0==model.phone.length?@"":model.phone)];
        if (!success) {
            [self addAddressBookWithFirstName:(0==model.name.length?@"":model.name) phoneNumber:(0==model.phone.length?@"":model.phone)];
        }
    }
    success?success():nil;
}


/**
 *  删除通讯录中的联系人数组
 */
-(void)deleteContactFromContactList:(NSMutableArray<XWPersonModel *> *)modelArray SuccessBlock:(void (^) (void)) success FaildBlock:(void(^)(void))faild{
    removeCount=0;
    for (XWPersonModel *model in modelArray) {
        //遍历删除
        [self removeAddressBookWithFirstName:(0==model.name.length?@"":model.name) phoneNumber:(0==model.phone.length?@"":model.phone)];
    }
    success?success():nil;
}

//改
- (BOOL)updateAddressBookWithFirstName:(NSString *)firstName phoneNumber:(NSString *)phoneNumber{
    if (firstName.length == 0 && phoneNumber.length == 0) {
        return NO;
    }
    ABAddressBookRef addressBookRef = [self getAddressBookRef];
    if (addressBookRef == nil) {
        return nil;
    }
    //获取所有本地的通讯录
    NSArray * records = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBookRef);
    BOOL isHave = NO;
    for (id record in records) {
        //单个联系人对象
        ABRecordRef recordRef = (__bridge ABRecordRef)record;
        //名
        NSString * oldFirstName = (__bridge NSString *)ABRecordCopyValue(recordRef, kABPersonFirstNameProperty);
        if (!oldFirstName) {
            oldFirstName = @"";
        }
        //移动电话
        ABMultiValueRef phoneMulti = ABRecordCopyValue(recordRef, kABPersonPhoneProperty);
        NSArray * phoneNumbers = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(phoneMulti);
        //如果有匹配的
        if ([firstName isEqualToString:oldFirstName]&&[phoneNumbers containsObject:phoneNumber]) {
            //修改
            ABRecordSetValue(recordRef, kABPersonFirstNameProperty, (__bridge CFStringRef)firstName, nil);
            ABMultiValueRef newPhone = ABMultiValueCreateMutable(kABPersonPhoneProperty);
            ABMultiValueIdentifier identifier;
            ABMultiValueAddValueAndLabel(newPhone, (__bridge CFStringRef)phoneNumber, (__bridge CFStringRef)@"手机", &identifier);
            BOOL update=ABRecordSetValue(recordRef, kABPersonPhoneProperty, newPhone, nil);
            if (update) {
                updateCount++;
            }
            isHave = YES;
        }
    }
    //保存
    BOOL isSuccess = ABAddressBookSave(addressBookRef, nil);
    return (isSuccess&&isHave);
    return NO;
}

///增
- (BOOL)addAddressBookWithFirstName:(NSString *)firstName phoneNumber:(NSString *)phoneNumber{
    if (firstName.length == 0 && phoneNumber.length == 0) {
        return NO;
    }
    ABAddressBookRef addressBookRef = [self getAddressBookRef];
    if (addressBookRef == nil) {
        return NO;
    }
    BOOL isSuccess = NO;
    //创建通讯录模版
    ABRecordRef recordRef = ABPersonCreate();
    //插入名
    isSuccess = ABRecordSetValue(recordRef, kABPersonFirstNameProperty, (__bridge CFStringRef)firstName, nil);
    //插入电话号码
    ABMultiValueRef phone = ABMultiValueCreateMutable(kABStringPropertyType);
    ABMultiValueIdentifier identifier;
    ABMultiValueAddValueAndLabel(phone, (__bridge CFStringRef)phoneNumber, (__bridge CFStringRef)@"手机", &identifier);
    isSuccess = ABRecordSetValue(recordRef, kABPersonPhoneProperty, phone, nil);
    //将准备好的联系人添加到通讯录里面
    isSuccess = ABAddressBookAddRecord(addressBookRef, recordRef, nil);
    //保存修改过的通讯录
    isSuccess = ABAddressBookSave(addressBookRef, nil);
    if (isSuccess) {
        addCount++;
    }
    if (recordRef) {
        CFRelease(recordRef);
    }
    if (phone) {
        CFRelease(phone);
    }
    return isSuccess;
}

//删
- (BOOL)removeAddressBookWithFirstName:(NSString *)firstName  phoneNumber:(NSString *)phoneNumber{
    if (0 == firstName.length && 0== phoneNumber.length ) {
        return NO;
    }
    //全部联系人对象
    NSArray * records = [self getAllAddressBooksWithIsFormat:NO];
    // 通讯录对象
    ABAddressBookRef addressBookRef = [self getAddressBookRef];
    //遍历循环删除
    for (id record in records) {
        //单个联系人对象
        ABRecordRef recordRef = (__bridge ABRecordRef)record;
        //名
        NSString * oldFirstName = (__bridge NSString *)ABRecordCopyValue(recordRef, kABPersonFirstNameProperty);
        if (!oldFirstName) {
            oldFirstName = @"";
        }
        //移动电话
        ABMultiValueRef phoneMulti = ABRecordCopyValue(recordRef, kABPersonPhoneProperty);
        NSArray * phoneNumbers = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(phoneMulti);
        //如果有匹配的
        if ([firstName isEqualToString:oldFirstName] &&[phoneNumbers containsObject:phoneNumber]) {
            //删除
            if (ABAddressBookRemoveRecord(addressBookRef, recordRef, nil)) {
                removeCount ++;
            }
        }
    }
    //保存
    BOOL isSuccess = ABAddressBookSave(addressBookRef, nil);
    return isSuccess;
}

//获取全部通讯录信息
- (id)getAllAddressBooksWithIsFormat:(BOOL)isFormat{
    ABAddressBookRef addressBookRef = [self getAddressBookRef];
    if (addressBookRef == nil) {
        return nil;
    }
    //获取所有本地的通讯录
    NSArray * records = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBookRef);
    if (!isFormat) {
        return records;
    }
    //格式化信息，根据自己的需求而定
    NSMutableDictionary * allAddressBook = [[NSMutableDictionary alloc] init];
    for (id record in records) {
        ABRecordRef tempRecord = (__bridge ABRecordRef)record;
        //获取名
        NSString * firstName = (__bridge NSString *)ABRecordCopyValue(tempRecord, kABPersonFirstNameProperty);
        if (!firstName) {
            firstName = @"";
        }
        //组合姓名
        NSString * name = firstName;
        //组合移动电话信息
        ABMultiValueRef phoneMulti = ABRecordCopyValue(tempRecord, kABPersonPhoneProperty);
        NSArray * phoneNumbers = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(phoneMulti);
        NSMutableString * phoneNumber = [[NSMutableString alloc] initWithString:@""];
        for (NSString * pN in phoneNumbers) {
            NSString * tempPN = (NSString *)[self transitionStringWithSting:pN];
            if (phoneNumber.length == 0) {
                [phoneNumber insertString:tempPN atIndex:phoneNumber.length];
            }else{
                [phoneNumber insertString:[NSString stringWithFormat:@"_%@",tempPN] atIndex:phoneNumber.length];
            }
        }
        [allAddressBook setObject:name forKey:phoneNumber];
    }
    return allAddressBook;
}



//创建通讯录对象，注意不会自动释放
- (ABAddressBookRef)getAddressBookRef{
    ABAddressBookRef  addressBookRef = ABAddressBookCreateWithOptions(nil, nil);
    if (addressBookRef) {
        CFAutorelease(addressBookRef);
    }
    return addressBookRef;
}


//格式化电话号码
- (id)transitionStringWithSting:(NSString *)str{
    BOOL isNSString;
    if ([str isKindOfClass:[NSString class]]) {
        isNSString = YES;
    }else{
        isNSString = NO;
    }
    str = [str stringByReplacingOccurrencesOfString:@"-" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"_" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"*" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"#" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"~" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (isNSString) {
        return str;  
    }  
    return [[NSMutableString alloc] initWithString:str];  
}  


//授权
- (void)requestAuthorizationWithSuccessBlock:(void(^)(void))success  faildBlock:(void(^)(void))faild{
    // 3.创建通讯录进行授权
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        if (granted) {
          success();
        } else {
          faild();
        }
    });
}

//单例
+ (XW_AddressHandler_ios9Ago *)Handler_ios9Ago{
    static XW_AddressHandler_ios9Ago *handler=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        handler=[[self alloc]init];
    });
    return handler;
};

//权限提醒
- (void)alertWithMessage:(NSString *)toastMessage{
    UIAlertController *phoneAlert=[UIAlertController alertControllerWithTitle:@"提醒" message:toastMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel=[UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [phoneAlert addAction:cancel];
    [KeyWindow.rootViewController presentViewController:phoneAlert animated:YES completion:nil];
}

///查
//- (id)getAddressBookWithFirstName:(NSString *)firstName phoneNumber:(NSString *)phoneNumber isFormat:(BOOL)isFormat{
//    if (firstName.length == 0 && phoneNumber.length == 0) {
//        return nil;
//    }
//    ABAddressBookRef addressBookRef = [self getAddressBookRef];
//    if (addressBookRef == nil) {
//        return nil;
//    }
//    NSMutableArray * tempRecords = nil;
//    NSMutableDictionary * tempRecordDic = nil;
//    if (isFormat) {
//        tempRecordDic = [[NSMutableDictionary alloc] init];
//    }else{
//        tempRecords = [[NSMutableArray alloc] init];
//    }
//    //获取所有本地的通讯录
//    NSArray * records = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBookRef);
//    for (id record in records) {
//        //单个联系人对象
//        ABRecordRef recordRef = (__bridge ABRecordRef)record;
//        //名
//        NSString * oldFirstName = (__bridge NSString *)ABRecordCopyValue(recordRef, kABPersonFirstNameProperty);
//        if (!oldFirstName) {
//            oldFirstName = @"";
//        }
//        //移动电话
//        ABMultiValueRef phoneMulti = ABRecordCopyValue(recordRef, kABPersonPhoneProperty);
//        NSArray * phoneNumbers = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(phoneMulti);
//        NSMutableString * oldPhoneNumber = [[NSMutableString alloc] initWithString:@""];
//        for (NSString * pN in phoneNumbers) {
//            NSString * tempPN = (NSString *)[self transitionStringWithSting:pN];
//            if (oldPhoneNumber.length == 0) {
//                [oldPhoneNumber insertString:tempPN atIndex:oldPhoneNumber.length];
//            }else{
//                [oldPhoneNumber insertString:[NSString stringWithFormat:@"_%@",tempPN] atIndex:oldPhoneNumber.length];
//            }
//        }
//        BOOL isEqual[3];
//        if (firstName.length == 0) {
//            isEqual[0] = YES;
//        }else if ([firstName isEqualToString:oldFirstName]){
//            isEqual[0] = YES;
//        }else{
//            isEqual[0] = NO;
//        }
//
//        if (phoneNumber.length == 0) {
//            isEqual[1] = YES;
//        }else if ([phoneNumber isEqualToString:oldPhoneNumber]){
//            isEqual[1] = YES;
//        }else{
//            isEqual[1] = NO;
//        }
//        if (isEqual[0] && isEqual[1]) {
//            // 格式化信息，根据自己的需求而定
//            if (isFormat) {
//                [tempRecordDic setObject:oldFirstName forKey:oldPhoneNumber];
//            }else{
//                [tempRecords addObject:(__bridge id)(recordRef)];
//            }
//        }
//    }
//    if (isFormat) {
//        return tempRecordDic;
//    }
//    return tempRecords;
//}


@end
