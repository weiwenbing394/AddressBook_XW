//
//  PPAddressModel.m
//  PPAddressBook
//
//  Created by AndyPang on 16/8/17.
//  Copyright © 2016年 AndyPang. All rights reserved.
//

#import "PPPersonModel.h"

@implementation PPPersonModel

- (NSMutableArray *)mobileArray{
    if(!_mobileArray){
        _mobileArray = [NSMutableArray array];
    }
    return _mobileArray;
}

- (NSMutableArray *)addressArray{
    if (!_addressArray) {
        _addressArray=[NSMutableArray array];
    }
    return _addressArray;
}

- (NSMutableArray *)emailArray{
    if (!_emailArray) {
        _emailArray=[NSMutableArray array];
    }
    return _emailArray;
}

@end
