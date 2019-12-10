//
//  HashMap.h
//  HashMap
//
//  Created by cuiyuheMacAir on 2019/9/28.
//  Copyright © 2019年 qinger. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HashMapNode;


@interface HashMap<KeyType, ObjectType> : NSObject

@property (nonatomic, assign, readonly) NSUInteger size;

- (BOOL)isEmpty;
- (BOOL)containsKey:(KeyType)key;
- (BOOL)containsValue:(ObjectType)value;
- (void)clear;
- (id)putWithKey:(KeyType)key value:(ObjectType)value;
- (id)getWithKey:(KeyType)key;
- (id)removeWithKey:(KeyType)key;
- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(KeyType key, ObjectType obj, BOOL *stop))block;


#pragma mark --- 子类重写
- (__kindof HashMapNode *)createNodeWithKey:(id)key value:(id)value parent:(HashMapNode *)parent;
- (void)afterRemove:(__kindof HashMapNode *)willNode removedNode:(__kindof HashMapNode *)removedNode;


@end

