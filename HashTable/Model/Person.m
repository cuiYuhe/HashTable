//
//  Person.m
//  HashMap
//
//  Created by cuiyuheMacAir on 2019/9/28.
//  Copyright © 2019年 qinger. All rights reserved.
//

#import "Person.h"

@implementation Person

+ (Person *)personWithAge:(int)age height:(CGFloat)height name:(NSString *)name{
    Person *p = [[self alloc] init];
    p.age = age;
    p.height = height;
    p.name = name;
    return p;
}

- (BOOL)isEqual:(id)object{
    if (self == object) {
        return YES;
    }
    
    if (object == nil || self.class != [object class]) {
        return NO;
    }
    
    Person *p = (Person *)object;
    return self.age == p.age &&
           self.height == p.height &&
           [self _isString:self.name equalToString:p.name];
}

- (NSUInteger)hash{
    NSUInteger v = (1 << 5) - 1;
    NSUInteger result = [NSNumber numberWithInt:self.age].hash;
    result = v*result + [NSNumber numberWithFloat:self.height].hash;
    result = v*result + self.name.hash;
    return result;
}

- (BOOL)_isString:(NSString *)str1 equalToString:(NSString *)str2{
    return str1 == nil ? str2 == nil : [str1 isEqualToString:str2];
}

@end
