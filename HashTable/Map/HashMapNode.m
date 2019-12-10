//
//  HashMapNode.m
//  HashTable
//
//  Created by cuiyuheMacAir on 2019/11/4.
//  Copyright © 2019年 qinger. All rights reserved.
//

#import "HashMapNode.h"

BOOL const RED = NO;
BOOL const BLACK = YES;


@implementation HashMapNode

+ (HashMapNode *)nodeWithKey:(id)key value:(nullable id)value parent:(HashMapNode *)parent{
    HashMapNode *node = [[self alloc] init];
    node.key = key;
    node.value = value;
    node.parent = parent;
    node.color = RED;
    NSUInteger hashCode = [key hash];
    node.hashCode = hashCode ^ (hashCode >> 16);
//    YHLog(@"hashCode = %zd", node.hashCode);
    return node;
}

- (BOOL)isLeftChild{
    return self == self.parent.left;
}
- (BOOL)isRightChild{
    return self == self.parent.right;
}

///是不是叶子节点
- (BOOL)isLeaf {
    return self.left == nil && self.right == nil;
}

/// 是否度为2
- (BOOL)isTwoDegrees{
    return self.left != nil && self.right != nil;
}

///兄弟节点
- (HashMapNode *)sibling{
    if ([self isLeftChild]) {
        return self.parent.right;
    }else if([self isRightChild]){
        return self.parent.left;
    }
    return nil;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"node_key: %@, value: %@", self.key, self.value];
}

@end
