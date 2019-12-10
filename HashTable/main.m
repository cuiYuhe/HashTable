//
//  main.m
//  HashTable
//
//  Created by cuiyuheMacAir on 2019/12/9.
//  Copyright © 2019年 qinger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HashMap.h"
#import "LinkedHashMap.h"
#import "Person.h"
#import "YHValue.h"

void testHashMap(void);
void testLinkedHashMap(void);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
//        testHashMap();
        testLinkedHashMap();
    }
    return 0;
}


/**
 hashMap, 即没有顺序的hashMap
 */
void testHashMap(void){
    
    id k1 = [NSObject new];
    id k2 = @"iOS";
    id k3 = @"Java";
    id k4 = @"python";
    id k5 = @"unity";
    id k6 = @"cocos";
    id k7 = [Person personWithAge:5 height:1.2 name:@"son"];
    id k8 = [Person personWithAge:5 height:1.2 name:@"son"];
    id k9 = [Person personWithAge:10 height:1.5 name:@"daught"];

    HashMap *map = [HashMap new];
    [map putWithKey:k1 value:@1];
    [map putWithKey:k2 value:@2];
    [map putWithKey:k3 value:@3];
    [map putWithKey:k4 value:@4];
    [map putWithKey:k5 value:@5];
    [map putWithKey:k6 value:@6];
    [map putWithKey:k7 value:@7];
    [map putWithKey:k8 value:@8];
    [map putWithKey:k9 value:@9];

    [map enumerateKeysAndObjectsUsingBlock:^(id key, NSNumber *obj, BOOL *stop) {
        if ([obj isEqualToNumber:@9]) {
            *stop = YES;
        }
        NSLog(@"id: %@, obj: %@", key, obj);
    }];
    
    assert([map containsKey:k1]);
    assert([map containsKey:k7]);
    assert([map containsValue:@9]);
    assert([map containsValue:@99]);

}


/**
 有顺序的hashMap
 */
void testLinkedHashMap(void){
    id k1 = [NSObject new];
    id k2 = @"love2";
    id k3 = @"respect3";
    id k4 = @"family4";
    id k5 = @"family5";
    id k6 = @"up6";
    id k7 = [Person personWithAge:5 height:1.2 name:@"son"];
    id k8 = [Person personWithAge:5 height:1.2 name:@"son"];
    id k9 = [Person personWithAge:10 height:1.5 name:@"daught"];
    
    LinkedHashMap *map = [LinkedHashMap new];
    [map putWithKey:k1 value:@1];
    [map putWithKey:k2 value:@2];
    [map putWithKey:k3 value:@3];
    [map putWithKey:k4 value:@4];
    [map putWithKey:k5 value:@5];
    [map putWithKey:k6 value:@6];
    
    YHValue *v1 = [YHValue valueWithValue:1 type:@"iOS"];
    [map putWithKey:k7 value:v1];
    //v1值被替换,因为key相同
    [map putWithKey:k8 value:[YHValue valueWithValue:1 type:@"Ruby"]];
    [map putWithKey:k9 value:[YHValue valueWithValue:1 type:@"iOS"]];
    
    [map enumerateKeysAndObjectsUsingBlock:^(id key, NSNumber *obj, BOOL *stop) {
        NSLog(@"id: %@, obj: %@", key, obj);
    }];
    
    assert([map containsKey:k4]);
    assert([map containsKey:k5]);
    assert([map containsValue:v1]);
    assert([map containsValue:[YHValue valueWithValue:1 type:@"Ruby"]]);
}
