//
//  PPAddressBook.m
//  PPAddressBook
//
//  Created by AndyPang on 16/8/17.
//  Copyright © 2016年 AndyPang. All rights reserved.
//

#import "PPGetAddressBook.h"
#define kPPAddressBookHandle [PPAddressBookHandle sharedAddressBookHandle]
#define START NSDate *startTime = [NSDate date]
#define END NSLog(@"Time: %f", -[startTime timeIntervalSinceNow])

@implementation PPGetAddressBook

#pragma mark - 获取原始顺序所有联系人
+ (void)getOriginalAddressBook:(AddressBookArrayBlock)addressBookArray FaildBlock:(void(^)(void))faild{
    // 将耗时操作放到子线程
    dispatch_queue_t queue = dispatch_queue_create("addressBook.array", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        [kPPAddressBookHandle getAddressBookDataSource:^(NSMutableArray *modelArray) {
            //将联系人数组回调到主线程
            dispatch_async(dispatch_get_main_queue(), ^{
                addressBookArray ? addressBookArray(modelArray) : nil ;
            });
        } FaildBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                faild();
            });
        }];
    });
}

#pragma mark - 获取按A~Z顺序排列的所有联系人
+ (void)getOrderAddressBook:(AddressBookDictBlock)addressBookInfo FaildBlock:(void(^)(void))faild{
    // 将耗时操作放到子线程
    dispatch_queue_t queue = dispatch_queue_create("addressBook.infoDict", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        NSMutableDictionary *addressBookDict = [NSMutableDictionary dictionary];
        [kPPAddressBookHandle getAddressBookDataSource:^(NSMutableArray *modelArray) {
            for (PPPersonModel *model in modelArray) {
                //获取到姓名的大写首字母
                NSString *firstLetterString = [self getFirstLetterFromString:model.name];
                //如果该字母对应的联系人模型不为空,则将此联系人模型添加到此数组中
                if (addressBookDict[firstLetterString]){
                    [addressBookDict[firstLetterString] addObject:model];
                }
                //没有出现过该首字母，则在字典中新增一组key-value
                else{
                    //创建新发可变数组存储该首字母对应的联系人模型
                    NSMutableArray *arrGroupNames = [NSMutableArray arrayWithObject:model];
                    //将首字母-姓名数组作为key-value加入到字典中
                    [addressBookDict setObject:arrGroupNames forKey:firstLetterString];
                }
            }
            // 将addressBookDict字典中的所有Key值进行排序: A~Z
            NSArray *nameKeys = [[addressBookDict allKeys] sortedArrayUsingSelector:@selector(compare:)];
            // 将 "#" 排列在 A~Z 的后面
            if ([nameKeys.firstObject isEqualToString:@"#"]){
                NSMutableArray *mutableNamekeys = [NSMutableArray arrayWithArray:nameKeys];
                [mutableNamekeys insertObject:nameKeys.firstObject atIndex:nameKeys.count];
                [mutableNamekeys removeObjectAtIndex:0];
                dispatch_async(dispatch_get_main_queue(), ^{
                    addressBookInfo ? addressBookInfo(addressBookDict,mutableNamekeys) : nil;
                });
                return;
            }
            // 将排序好的通讯录数据回调到主线程
            dispatch_async(dispatch_get_main_queue(), ^{
                addressBookInfo ? addressBookInfo(addressBookDict,nameKeys) : nil;
            });
        }FaildBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                faild();
            });
        }];
    });
}


#pragma mark - 获取联系人姓名首字母(传入汉字字符串, 返回大写拼音首字母)
+ (NSString *)getFirstLetterFromString:(NSString *)aString{
    NSMutableString *mutableString = [NSMutableString stringWithString:aString];
    CFStringTransform((CFMutableStringRef)mutableString, NULL, kCFStringTransformToLatin, false);
    NSString *pinyinString = [mutableString stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
    // 将拼音首字母装换成大写
    NSString *strPinYin = [[self polyphoneStringHandle:aString pinyinString:pinyinString] uppercaseString];
    // 截取大写首字母
    NSString *firstString = [strPinYin substringToIndex:1];
    // 判断姓名首位是否为大写字母
    NSString * regexA = @"^[A-Z]$";
    NSPredicate *predA = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexA];
    // 获取并返回首字母
    return [predA evaluateWithObject:firstString] ? firstString : @"#";
}

/**
 多音字处理
 */
+ (NSString *)polyphoneStringHandle:(NSString *)aString pinyinString:(NSString *)pinyinString{
    if ([aString hasPrefix:@"长"]) { return @"chang";}
    if ([aString hasPrefix:@"沈"]) { return @"shen"; }
    if ([aString hasPrefix:@"厦"]) { return @"xia";  }
    if ([aString hasPrefix:@"地"]) { return @"di";   }
    if ([aString hasPrefix:@"重"]) { return @"chong";}
    return pinyinString;
}

@end
