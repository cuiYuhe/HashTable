//
//  YHValue.m
//  HashTable
//
//  Created by cuiyuheMacAir on 2019/12/9.
//  Copyright © 2019年 qinger. All rights reserved.
//

#import "YHValue.h"

@implementation YHValue
{
    int _value;
    NSString * _type;
}

+ (YHValue *)valueWithValue:(int)v type:(NSString *)t{
    YHValue *value = [self new];
    value->_value = v;
    value->_type = t;
    return value;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"v:%d, type:%@", self->_value, self->_type];
}

@end
