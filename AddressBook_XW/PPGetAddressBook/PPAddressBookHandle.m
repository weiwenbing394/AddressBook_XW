//
//  PPDataHandle.m
//  PPAddressBook
//
//  Created by AndyPang on 16/8/17.
//  Copyright © 2016年 AndyPang. All rights reserved.
//

#import "PPAddressBookHandle.h"
@interface PPAddressBookHandle ()
#ifdef __IPHONE_9_0
/** iOS9之后的通讯录对象*/
@property (nonatomic, strong) CNContactStore *contactStore;
#endif

@end

@implementation PPAddressBookHandle

PPSingletonM(AddressBookHandle)


/**
 *  返回所有联系人模型
 *
 */
- (void)getAddressBookDataSource:(PPPersonModelArrayBlock)personModelArray FaildBlock:(void(^)(void))faild{
    if(IOS9_LATER){
        [self getDataSourceFrom_IOS9_Later:personModelArray FaildBlock:^{
            faild();
        }];
    }else{
        [self getDataSourceFrom_IOS9_Ago:personModelArray FaildBlock:^{
            faild();
        }];
    }
}

#pragma mark - IOS9之前获取通讯录的方法
- (void)getDataSourceFrom_IOS9_Ago:(PPPersonModelArrayBlock)ModelArray FaildBlock:(void(^)(void))faild{
    
    NSMutableArray *personModelArray=[NSMutableArray array];
    // 1.获取授权状态
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    // 2.如果没有授权,先执行授权
    if (status == kABAuthorizationStatusAuthorized){
        // 3.创建通信录对象
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        //4.按照排序规则从通信录对象中请求所有的联系人,并按姓名属性中的姓(LastName)来排序
        ABRecordRef recordRef = ABAddressBookCopyDefaultSource(addressBook);
        CFArrayRef allPeopleArray = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, recordRef, kABPersonSortByLastName);
        // 5.遍历每个联系人的信息,并装入模型
        for(id personInfo in (__bridge NSArray *)allPeopleArray){
            PPPersonModel *model = [PPPersonModel new];
            // 5.1获取到联系人
            ABRecordRef person = (__bridge ABRecordRef)(personInfo);
            // 5.2获取全名
            NSString *name = (__bridge_transfer NSString *)ABRecordCopyCompositeName(person);
            model.name = name.length > 0 ? name : @"无名氏" ;
            // 5.3获取头像数据
            NSData *imageData = (__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail);
            model.headerImage = [UIImage imageWithData:imageData];
            // 5.4获取每个人所有的电话号码
            ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
            CFIndex phoneCount = ABMultiValueGetCount(phones);
            for (CFIndex i = 0; i < phoneCount; i++){
                // 号码
                NSString *phoneValue = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phones, i);
                NSString *mobile = [self removeSpecialSubString:phoneValue];
                [model.mobileArray addObject: mobile ? mobile : @"空号"];
            }
            [personModelArray addObject:model];
            CFRelease(phones);
        }
        // 5.5将联系人模型回调出去
        ModelArray ? ModelArray(personModelArray) : nil;
        // 释放不再使用的对象
        CFRelease(allPeopleArray);
        CFRelease(recordRef);
        CFRelease(addressBook);
    }else{
        [self requestAuthorizationWithSuccessBlock:^{
            // 3.创建通信录对象
            ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
            //4.按照排序规则从通信录对象中请求所有的联系人,并按姓名属性中的姓(LastName)来排序
            ABRecordRef recordRef = ABAddressBookCopyDefaultSource(addressBook);
            CFArrayRef allPeopleArray = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, recordRef, kABPersonSortByLastName);
            // 5.遍历每个联系人的信息,并装入模型
            for(id personInfo in (__bridge NSArray *)allPeopleArray){
                PPPersonModel *model = [PPPersonModel new];
                // 5.1获取到联系人
                ABRecordRef person = (__bridge ABRecordRef)(personInfo);
                // 5.2获取全名
                NSString *name = (__bridge_transfer NSString *)ABRecordCopyCompositeName(person);
                model.name = name.length > 0 ? name : @"无名氏" ;
                // 5.3获取头像数据
                NSData *imageData = (__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail);
                model.headerImage = [UIImage imageWithData:imageData];
                // 5.4获取每个人所有的电话号码
                ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
                CFIndex phoneCount = ABMultiValueGetCount(phones);
                for (CFIndex i = 0; i < phoneCount; i++){
                    // 号码
                    NSString *phoneValue = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phones, i);
                    NSString *mobile = [self removeSpecialSubString:phoneValue];
                    [model.mobileArray addObject: mobile ? mobile : @"空号"];
                }
                [personModelArray addObject:model];
                CFRelease(phones);
            }
            // 5.5将联系人模型回调出去
            ModelArray ? ModelArray(personModelArray) : nil;
            // 释放不再使用的对象
            CFRelease(allPeopleArray);
            CFRelease(recordRef);
            CFRelease(addressBook);
        } faildBlock:^{
            faild();
        }];
    }
}


#pragma mark - IOS9之后获取通讯录的方法
- (void)getDataSourceFrom_IOS9_Later:(PPPersonModelArrayBlock)ModelArray FaildBlock:(void(^)(void))faild{
    NSMutableArray *personModelArray=[NSMutableArray array];
#ifdef __IPHONE_9_0
    // 1.获取授权状态
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    // 2.如果没有授权,先执行授权失败的block后return
    if (status == CNAuthorizationStatusAuthorized){
        // 3.2.创建联系人的请求对象
        // keys决定能获取联系人哪些信息,例:姓名,电话,头像等
        NSArray *fetchKeys = @[[CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName],CNContactPhoneNumbersKey,CNContactThumbnailImageDataKey];
        CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:fetchKeys];
        // 3.3.请求联系人
        [self.contactStore enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact * _Nonnull contact,BOOL * _Nonnull stop) {
            // 获取联系人全名
            NSString *name = [CNContactFormatter stringFromContact:contact style:CNContactFormatterStyleFullName];
            // 创建联系人模型
            PPPersonModel *model = [PPPersonModel new];
            model.name = name.length > 0 ? name : @"无名氏" ;
            // 联系人头像
            model.headerImage = [UIImage imageWithData:contact.thumbnailImageData];
            // 获取一个人的所有电话号码
            NSArray *phones = contact.phoneNumbers;
            for (CNLabeledValue *labelValue in phones){
                CNPhoneNumber *phoneNumber = labelValue.value;
                NSString *mobile = [self removeSpecialSubString:phoneNumber.stringValue];
                [model.mobileArray addObject: mobile ? mobile : @"空号"];
            }
            [personModelArray addObject:model];
        }];
        //将联系人模型回调出去
        ModelArray ? ModelArray(personModelArray) : nil;
    }else{
        [self requestAuthorizationWithSuccessBlock:^{
            // 3.2.创建联系人的请求对象
            // keys决定能获取联系人哪些信息,例:姓名,电话,头像等
            NSArray *fetchKeys = @[[CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName],CNContactPhoneNumbersKey,CNContactThumbnailImageDataKey];
            CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:fetchKeys];
            // 3.3.请求联系人
            [self.contactStore enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact * _Nonnull contact,BOOL * _Nonnull stop) {
                // 获取联系人全名
                NSString *name = [CNContactFormatter stringFromContact:contact style:CNContactFormatterStyleFullName];
                // 创建联系人模型
                PPPersonModel *model = [PPPersonModel new];
                model.name = name.length > 0 ? name : @"无名氏" ;
                // 联系人头像
                model.headerImage = [UIImage imageWithData:contact.thumbnailImageData];
                // 获取一个人的所有电话号码
                NSArray *phones = contact.phoneNumbers;
                for (CNLabeledValue *labelValue in phones){
                    CNPhoneNumber *phoneNumber = labelValue.value;
                    NSString *mobile = [self removeSpecialSubString:phoneNumber.stringValue];
                    [model.mobileArray addObject: mobile ? mobile : @"空号"];
                }
                [personModelArray addObject:model];
            }];
            //将联系人模型回调出去
            ModelArray ? ModelArray(personModelArray) : nil;
        } faildBlock:^{
            faild();
        }];
    }
#endif
}

- (void)requestAuthorizationWithSuccessBlock:(void(^)(void))success  faildBlock:(void(^)(void))faild{
    if(IOS9_LATER){
#ifdef __IPHONE_9_0
        // 3.授权
        [self.contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                success();
            }else{
                faild();
            }
        }];
#endif
    }else{
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
}


//过滤指定字符串(可自定义添加自己过滤的字符串)
- (NSString *)removeSpecialSubString: (NSString *)string{
    string = [string stringByReplacingOccurrencesOfString:@"+86" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"-" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"(" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@")" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    return string;
}

#pragma mark - lazy

#ifdef __IPHONE_9_0
- (CNContactStore *)contactStore{
    if(!_contactStore){
        _contactStore = [[CNContactStore alloc] init];
    }
    return _contactStore;
}
#endif

@end
