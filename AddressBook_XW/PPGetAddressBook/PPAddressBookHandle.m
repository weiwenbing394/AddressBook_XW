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
 *  返回所有联系人
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
    // 1.获取授权状态
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    NSLog(@"这里");
    // 2.如果没有授权,先执行授权
    if (status == kABAuthorizationStatusAuthorized){
        [self DataSourceFrom_IOS9_Ago:ModelArray];
    }else{
        [self requestAuthorizationWithSuccessBlock:^{
            [self DataSourceFrom_IOS9_Ago:ModelArray];
        } faildBlock:^{
            faild();
        }];
    }
}

#pragma mark - IOS9之前获取通讯录数据
- (void)DataSourceFrom_IOS9_Ago:(PPPersonModelArrayBlock)ModelArray{
    NSMutableArray *personModelArray=[NSMutableArray array];
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
        model.name = name.length > 0 ? name : @"#" ;
        // 5.3获取头像数据
        NSData *imageData = (__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail);
        model.headerImage =imageData? [UIImage imageWithData:imageData]:[UIImage imageNamed:@"defult-1.jpg"];
        // 5.4获取每个人所有的电话号码
        ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
        for (CFIndex i = 0; i <ABMultiValueGetCount(phones); i++){
            // 号码
            NSString *phoneValue = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phones, i);
            NSString *mobile = [self removeSpecialSubString:phoneValue];
            if (0<mobile.length) {
                [model.mobileArray addObject: mobile];
            }
        }
        if (0==model.mobileArray.count) {
            [model.mobileArray addObject:@""];
        }
        //获取每个人的地址
        ABMultiValueRef addresss = ABRecordCopyValue(person, kABPersonAddressProperty);
        for (CFIndex i = 0; i <ABMultiValueGetCount(addresss); i++){
            // 地址属性字典
            NSDictionary * dictionary = (__bridge NSDictionary *)ABMultiValueCopyValueAtIndex(addresss, i);
            //国家
            NSString  *country=[dictionary valueForKey:(__bridge NSString *)kABPersonAddressCountryKey];
            country=0<country.length?country:@"";
            //省(州)
            NSString  *state=[dictionary valueForKey:(__bridge NSString *)kABPersonAddressStateKey];
            state=0<state.length?state:@"";
            //城市
            NSString  *city=[dictionary valueForKey:(__bridge NSString *)kABPersonAddressCityKey];
            city=0<city.length?city:@"";
            //街道
            NSString  *street=[dictionary valueForKey:(__bridge NSString *)kABPersonAddressStreetKey];
            street=0<street.length?street:@"";
            //综合地址
            NSString *addressValue =[NSString stringWithFormat:@"%@%@%@%@",country,state,city,street];
            
            if (0<addressValue.length) {
                [model.addressArray addObject: addressValue];
            }
        }
        if (0==model.addressArray.count) {
            [model.addressArray addObject:@""];
        }
        //获取每个人的邮件地址
        ABMultiValueRef mails = ABRecordCopyValue(person, kABPersonEmailProperty);
        for (CFIndex i = 0; i <ABMultiValueGetCount(mails); i++){
            // 邮件
            NSString *mailValue = (__bridge NSString *)ABMultiValueCopyValueAtIndex(mails, i);
            if (0<mailValue.length) {
                [model.emailArray addObject: mailValue];
            }
        }
        if (0==model.emailArray.count) {
            [model.emailArray addObject:@""];
        }
        //获取工作信息
        NSString *organizationName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonOrganizationProperty);//公司(组织)名称
        organizationName=0<organizationName.length?organizationName:@"";
        NSString *departmentName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonDepartmentProperty);//部门
        departmentName=0<departmentName.length?departmentName:@"";
        NSString *jobTitle = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonJobTitleProperty);//职位
        jobTitle=0<jobTitle.length?jobTitle:@"";
        NSString *jobStr=[NSString stringWithFormat:@"%@%@%@",organizationName,departmentName,jobTitle];
        model.job=0<jobStr.length?jobStr:@"";
        
        [personModelArray addObject:model];
        CFRelease(phones);
        CFRelease(addresss);
        CFRelease(mails);
     }
    // 5.5将联系人模型回调出去
    ModelArray ? ModelArray(personModelArray) : nil;
    // 释放不再使用的对象
    CFRelease(allPeopleArray);
    CFRelease(recordRef);
    CFRelease(addressBook);

}


#pragma mark - IOS9之后获取通讯录的方法
- (void)getDataSourceFrom_IOS9_Later:(PPPersonModelArrayBlock)ModelArray FaildBlock:(void(^)(void))faild{
#ifdef __IPHONE_9_0
    // 1.获取授权状态
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    // 2.如果没有授权,先执行授权失败的block后return
    if (status == CNAuthorizationStatusAuthorized){
        [self DataSourceFrom_IOS9_Later:ModelArray];
    }else{
        [self requestAuthorizationWithSuccessBlock:^{
           //将联系人模型回调出去
           [self DataSourceFrom_IOS9_Later:ModelArray];
        } faildBlock:^{
            faild();
        }];
    }
#endif
}

#pragma mark - IOS9之后获取通讯录数据
- (void)DataSourceFrom_IOS9_Later:(PPPersonModelArrayBlock)ModelArray{
        NSMutableArray *personModelArray=[NSMutableArray array];
        // 3.2.创建联系人的请求对象，keys决定能获取联系人哪些信息,例:姓名,电话,头像等
        NSArray *fetchKeys = @[[CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName],CNContactPhoneNumbersKey,CNContactThumbnailImageDataKey,CNContactPostalAddressesKey,CNContactEmailAddressesKey,CNContactOrganizationNameKey,CNContactDepartmentNameKey,CNContactJobTitleKey];
        CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:fetchKeys];
        // 3.3.请求联系人
        [self.contactStore enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact * _Nonnull contact,BOOL * _Nonnull stop) {
            // 创建联系人模型
            PPPersonModel *model = [PPPersonModel new];
            // 获取联系人全名
            NSString *name = [CNContactFormatter stringFromContact:contact style:CNContactFormatterStyleFullName];
            model.name = 0<name.length ? name : @"#" ;
            // 联系人头像
            model.headerImage=contact.thumbnailImageData?[UIImage imageWithData:contact.thumbnailImageData]:[UIImage imageNamed:@"defult-1.jpg"];
            // 获取一个人的所有电话号码
            NSArray *phones = contact.phoneNumbers;
            for (CNLabeledValue *labelValue in phones){
                CNPhoneNumber *phoneNumber = labelValue.value;
                NSString *mobile = [self removeSpecialSubString:phoneNumber.stringValue];
                if (0<mobile.length) {
                    [model.mobileArray addObject: mobile];
                }
            }
            if (0==model.mobileArray.count) {
                [model.mobileArray addObject:@""];
            }
            //获取联系人地址
            NSArray *addresss=contact.postalAddresses;
            for (CNLabeledValue * labelValue in addresss) {
                CNPostalAddress *address=labelValue.value;
                NSString *addressStr=[NSString stringWithFormat:@"%@%@%@%@",address.country,address.state,address.city,address.street];
                if (0<addressStr.length) {
                    [model.addressArray addObject:addressStr];
                }
            }
            if (0==model.addressArray.count) {
                [model.addressArray addObject:@""];
            }
            //获取邮件
            NSArray *emalAddresss=contact.emailAddresses;
            for (CNLabeledValue * labelValue in emalAddresss) {
                NSString *emailAddress=labelValue.value;
                if (0<emailAddress.length) {
                    [model.emailArray addObject:emailAddress];
                }
            }
            if (0==model.emailArray.count) {
                [model.emailArray addObject:@""];
            }
            //获取工作信息
            NSString *organizationName = contact.organizationName;//公司(组织)名称
            NSString *departmentName = contact.departmentName;//部门
            NSString *jobTitle = contact.jobTitle;//职位
            NSString *jobStr=[NSString stringWithFormat:@"%@%@%@",organizationName,departmentName,jobTitle];
            model.job=0<jobStr.length?jobStr:@"";
            
            [personModelArray addObject:model];
        }];
        ModelArray ? ModelArray(personModelArray) : nil;
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
