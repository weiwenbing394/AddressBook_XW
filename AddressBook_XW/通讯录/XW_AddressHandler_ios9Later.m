//
//  XW_AddressHandler_ios9Later.m
//  DaJiaBaoMall
//
//  Created by 大家保 on 2017/4/5.
//  Copyright © 2017年 大家保. All rights reserved.
//

#import "XW_AddressHandler_ios9Later.h"
#import <AddressBook/AddressBook.h>
#import <Contacts/Contacts.h>
#define IOS9_LATER ([[UIDevice currentDevice] systemVersion].floatValue > 9.0 ? YES : NO )
#define KeyWindow [UIApplication sharedApplication].delegate.window
#define WeakSelf __weak typeof(self) weakSelf = self


@interface XW_AddressHandler_ios9Later (){
    // 删除数量
    int removeCount;
    //更新数量
    int updateCount;
    //增加数量
    int addCount;
}

@property (nonatomic, strong) CNContactStore *contactStore;

@end


@implementation XW_AddressHandler_ios9Later

//添加通讯录
- (void)addPersonArray:(NSMutableArray<XWPersonModel *> *)personModelArray SuccessBlock:(void (^) (void)) success FaildBlock:(void(^)(void))faild{
    WeakSelf;
    // 1.获取授权状态
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    // 2.如果没有授权,先执行授权
    if (status == kABAuthorizationStatusAuthorized){
        //开始添加
        dispatch_async(dispatch_get_main_queue(), ^{
           // [MBProgressHUD showHUDWithTitle:@"正在导入，请稍后..."];
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
               // [MBProgressHUD hiddenHUD];
                [weakSelf alertWithMessage:@"请在iphone的“设置-隐私-通讯录”选项中，允许圈圈访问您的通讯录"];
                faild?faild():nil;
            });
        }];
    }else{
        [weakSelf requestAuthorizationWithSuccessBlock:^{
            //开始添加
            dispatch_async(dispatch_get_main_queue(), ^{
               // [MBProgressHUD showHUDWithTitle:@"正在导入，请稍后..."];
            });
            [weakSelf addContactToContactList:personModelArray SuccessBlock:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    //[MBProgressHUD hiddenHUD];
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
                   // [MBProgressHUD hiddenHUD];
                    [weakSelf alertWithMessage:@"请在iphone的“设置-隐私-通讯录”选项中，允许圈圈访问您的通讯录"];
                    faild?faild():nil;
                });
            }];
        } faildBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
               // [MBProgressHUD hiddenHUD];
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
           // [MBProgressHUD showHUDWithTitle:@"正在清除，请稍后..."];
        });
        [weakSelf deleteContactFromContactList:personModelArray SuccessBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
               // [MBProgressHUD hiddenHUD];
                [weakSelf alertWithMessage:[NSString stringWithFormat:@"本次成功删除%d个联系人",removeCount]];
                success?success():nil;
            });
        } FaildBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
               // [MBProgressHUD hiddenHUD];
                [weakSelf alertWithMessage:@"请在iphone的“设置-隐私-通讯录”选项中，允许圈圈访问您的通讯录"];
                faild?faild():nil;
            });
        }];
    }else{
        [weakSelf requestAuthorizationWithSuccessBlock:^{
            //开始删除
            dispatch_async(dispatch_get_main_queue(), ^{
               // [MBProgressHUD showHUDWithTitle:@"正在清除，请稍后..."];
            });
            [weakSelf deleteContactFromContactList:personModelArray SuccessBlock:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                   // [MBProgressHUD hiddenHUD];
                    [weakSelf alertWithMessage:[NSString stringWithFormat:@"本次成功删除%d个联系人",removeCount]];
                    success?success():nil;
                });
            } FaildBlock:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                   // [MBProgressHUD hiddenHUD];
                    [weakSelf alertWithMessage:@"请在iphone的“设置-隐私-通讯录”选项中，允许圈圈访问您的通讯录"];
                    faild?faild():nil;
                });
            }];
        } faildBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                //[MBProgressHUD hiddenHUD];
                [weakSelf alertWithMessage:@"请在iphone的“设置-隐私-通讯录”选项中，允许圈圈访问您的通讯录"];
                faild?faild():nil;
            });        }];
    }
}


// 授权
- (void)requestAuthorizationWithSuccessBlock:(void(^)(void))success  faildBlock:(void(^)(void))faild{
    [self.contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            success();
        }else{
            faild();
        }
    }];
}

/**
 *  添加联系人数组到通讯录
 */
-(void)addContactToContactList:(NSMutableArray<XWPersonModel *> *)modelArray SuccessBlock:(void (^) (void)) success FaildBlock:(void(^)(void))faild{
    updateCount=0;
    addCount=0;
    for (XWPersonModel *model in modelArray) {
        NSArray<CNContact *> *contactArray=[self isHavePersonInContact:model];
        if (0<contactArray.count) {
            //联系人存在,循环遍历
            for (CNContact *contact in contactArray) {
                CNMutableContact *mutableContact=[contact mutableCopy];
                //更新联系人
                [self updateOneContectToContactList:mutableContact updateModel:model];
            }
         }else{
            //联系人不存在,添加
            [self addPeople:model];
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
        NSArray<CNContact *> *contactArray=[self isHavePersonInContact:model];
        if (0<contactArray.count) {
            //联系人存在,循环遍历
            for (CNContact *contact in contactArray) {
                CNMutableContact *mutableContact=[contact mutableCopy];
                //删除已存在的联系人
                [self deletePeople:mutableContact];
            }
        }
    }
    success?success():nil;
}

/**
 *  添加单个联系人到通讯录
 */
- (void)addPeople:(XWPersonModel *)model{
    @try {
        NSString *name= 0<model.name.length?model.name:@"";
        CNMutableContact * contact = [[CNMutableContact alloc]init];
        contact.familyName = name;
        if (0<model.phone.length) {
            CNLabeledValue *mobilePhone = [[CNLabeledValue alloc] initWithLabel:CNLabelPhoneNumberMobile value:[[CNPhoneNumber alloc] initWithStringValue:model.phone]];
            contact.phoneNumbers = @[mobilePhone];
        }
        //初始化方法
        CNSaveRequest * saveRequest = [[CNSaveRequest alloc]init];
        //添加联系人
        [saveRequest addContact:contact toContainerWithIdentifier:nil];
        CNContactStore * store = [[CNContactStore alloc]init];
        NSError *error;
        [store executeSaveRequest:saveRequest error:&error];
        if (error==nil) {
            addCount++;
        }
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

/**
 *  删除单个联系人
 */
- (void)deletePeople:(CNMutableContact *)mutableContact{
    @try {
        CNSaveRequest * saveRequest = [[CNSaveRequest alloc]init];
        //删除联系人
        [saveRequest deleteContact:mutableContact];
        //执行删除
        CNContactStore * store= [[CNContactStore alloc]init];
        NSError *error;
        [store executeSaveRequest:saveRequest error:&error];
        if (error==nil) {
            removeCount++;
        }
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

/**
 *  修改通讯录中的一位联系人
 *  先根据条件生成一个谓词，根据谓词读到联系人，并对联系人进行update
 */
-(void)updateOneContectToContactList:(CNMutableContact  *)updateContact updateModel:(XWPersonModel *)model{
    if (updateContact&&model) {
        //姓名
        NSString *name= 0<model.name.length?model.name:@"";
        updateContact.familyName=name;
        //电话
        if (0<model.phone.length) {
            CNPhoneNumber *mobileNumber = [[CNPhoneNumber alloc] initWithStringValue:model.phone];
            CNLabeledValue *mobilePhone = [[CNLabeledValue alloc] initWithLabel:CNLabelPhoneNumberMobile value:mobileNumber];
            updateContact.phoneNumbers = @[mobilePhone];
        }
        //开始更新
        CNSaveRequest * saveRequest = [[CNSaveRequest alloc]init];
        [saveRequest updateContact:updateContact];
        CNContactStore * store= [[CNContactStore alloc]init];
        NSError *error;
        [store executeSaveRequest:saveRequest error:&error];
        if (error==nil) {
            updateCount++;
        }
    }
}


/**
 *  根据姓名和电话判断要操作的联系人是否存在
 *  先根据条件生成一个谓词，根据谓词读到联系人，有的话返回联系人,没有的话返回nil
 */
-(NSArray<CNContact *> *)isHavePersonInContact:(XWPersonModel *)model{
    @try {
        //根据电话号码和姓名查询
        NSMutableArray<CNContact *> *backContacts=[NSMutableArray array];
        NSMutableArray<CNContact *> *phoneContacts=[self getContactList];
        for (CNContact *contact in phoneContacts) {
            CNMutableContact *mutabeContact=[contact mutableCopy];
            for (CNLabeledValue *labeledValue in mutabeContact.phoneNumbers) {
                //获取电话号码
                CNPhoneNumber *phoneNumer = labeledValue.value;
                NSString *phoneValue = phoneNumer.stringValue;
                //判断电话号码和姓名
                if ([phoneValue isEqualToString:model.phone]&&[model.name isEqualToString:mutabeContact.familyName]) {
                    [backContacts addObject:mutabeContact];
                }
            }
        }
        
        return backContacts;
        
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

/**
 *  读取联系人通讯录
 */
-(NSMutableArray<CNContact *> *)getContactList{
    NSMutableArray *array = [NSMutableArray array];
    // 1.创建通信录对象
    CNContactStore *contactStore = [[CNContactStore alloc] init];
    // 2.创建获取通信录的请求对象
    // 2.1.拿到所有打算获取的属性对应的key
    NSArray *keys = @[CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey,CNContactImageDataKey];
    // 2.2.创建CNContactFetchRequest对象
    CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:keys];
    // 3.遍历所有的联系人
    [contactStore enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
        [array addObject:contact];
    }];
    return array;
}

//懒加载
- (CNContactStore *)contactStore{
    if(!_contactStore){
        _contactStore = [[CNContactStore alloc] init];
    }
    return _contactStore;
}

//单例
+ (XW_AddressHandler_ios9Later *)Handler_ios9Later{
    static XW_AddressHandler_ios9Later *handler=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        handler=[[self alloc] init];
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




//备忘(根据筛选条件获取通讯录对象，此处用不上)
- (void)shaixuan{
//    //根据姓氏查询
//    CNContactStore * store= [[CNContactStore alloc]init];
//    NSString *name= 0<model.name.length?model.name:@"";
//    NSPredicate * predicate = [CNContact predicateForContactsMatchingName:name];
//    //提取数据,要修改的必需先提取出来，放在keysToFetch中提取
//    NSArray * contacts = [store unifiedContactsMatchingPredicate:predicate keysToFetch:@[CNContactFamilyNameKey] error:nil];
}

//备忘(根据名字判断用户的话，可以向同一用户添加新号码，而不是创建新用户，此处用不上)
- (void)update{
    //            NSArray<CNLabeledValue<CNPhoneNumber*>*> *array=updateContact.phoneNumbers;
    //            NSMutableArray<CNLabeledValue<CNPhoneNumber*>*> *arr=[NSMutableArray arrayWithArray:array];
    //            NSMutableArray *phoneStrArr=[NSMutableArray array];
    //            for (CNLabeledValue *labeledValue in array) {
    //                //获取电话号码
    //                CNPhoneNumber *phoneNumer = labeledValue.value;
    //                NSString *phoneValue = phoneNumer.stringValue;
    //                [phoneStrArr addObject:phoneValue];
    //            }
    //            if ([phoneStrArr containsObject:model.phone]==NO) {
    //                CNPhoneNumber *mobileNumber = [[CNPhoneNumber alloc] initWithStringValue:model.phone];
    //                CNLabeledValue *mobilePhone = [[CNLabeledValue alloc] initWithLabel:CNLabelPhoneNumberMobile value:mobileNumber];
    //                [arr addObject:mobilePhone];
    //            }
    //            updateContact.phoneNumbers = arr;
}


@end
