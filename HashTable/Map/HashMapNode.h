//
//  HashMapNode.h
//  HashTable
//
//  Created by cuiyuheMacAir on 2019/11/4.
//  Copyright © 2019年 qinger. All rights reserved.
//

#import <Foundation/Foundation.h>

extern BOOL const RED;
extern BOOL const BLACK;


@interface HashMapNode<KeyType, ObjectType> : NSObject

@property (nonatomic, strong) KeyType key;
@property (nonatomic, strong) ObjectType value;
@property (nonatomic, strong) HashMapNode<KeyType, ObjectType> *parent;
/// 左节点
@property (nonatomic, strong) HashMapNode<KeyType, ObjectType> *left;
/// 右节点
@property (nonatomic, strong) HashMapNode<KeyType, ObjectType> *right;
/// 兄弟节点
@property (nonatomic, strong, readonly) HashMapNode<KeyType, ObjectType> *siblingNode;
/// 是否叶子节点
@property (nonatomic, assign, readonly) BOOL isLeaf;
/// 是否度为2
@property (nonatomic, assign, readonly) BOOL isTwoDegrees;
@property (nonatomic, assign, readonly) BOOL isLeftChild;
@property (nonatomic, assign, readonly) BOOL isRightChild;
/// 当前节点颜色
@property (nonatomic, assign) BOOL color;
/// 保证只计算一次hash, key的hash值
@property (nonatomic, assign) NSUInteger hashCode;

+ (__kindof HashMapNode *)nodeWithKey:(id)key value:(nullable id)value parent:(HashMapNode *)parent;



@end


