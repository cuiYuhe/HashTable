//
//  LinkedHashMap.m
//  HashTable
//
//  Created by cuiyuheMacAir on 2019/11/4.
//  Copyright © 2019年 qinger. All rights reserved.
//

#import "LinkedHashMap.h"
#import "LinkedHashMapNode.h"

@implementation LinkedHashMap

- (HashMapNode *)createNodeWithKey:(id)key value:(id)value parent:(HashMapNode *)parent{
    
    LinkedHashMapNode *node = [LinkedHashMapNode nodeWithKey:key value:value parent:parent];
    if (self.first == nil) {
        self.first = self.last = node;
    }else{
        self.last.next = node;
        node.prev = self.last;
        self.last = node;
        
    }
    return node;
}

- (void)clear{
    [super clear];
    self.first = self.last = nil;
}

- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id _Nonnull, id _Nonnull, BOOL * _Nonnull))block{
    LinkedHashMapNode *node = self.first;
    BOOL stop = NO;
    while (node) {
        block(node.key, node.value, &stop);
        if (stop) {
            return;
        }
        node = node.next;
    }
}

- (void)afterRemove:(__kindof HashMapNode *)willNode removedNode:(__kindof HashMapNode *)removedNode{
    //cui:如果删除度为2的节点,需要交换链表中的位置,因为实际删除的是替代节点.不然链表遍历的顺序就不对了
    LinkedHashMapNode *node1 = (LinkedHashMapNode *)willNode;
    LinkedHashMapNode *node2 = (LinkedHashMapNode *)removedNode;
    if (node1 != node2) { //有替代节点,说明删除的是度为2的节点
        //交换prev
        LinkedHashMapNode *tmp = node1.prev;
        node1.prev = node2.prev;
        node2.prev = tmp;
        if (node1.prev == nil) {
            self.first = node1;
        }else{
            node1.prev.next = node1;
        }

        if (node2.prev == nil) {
            self.first = node2;
        }else{
            node2.prev.next = node2;
        }

        //交换next
        tmp = node1.next;
        node1.next = node2.next;
        node2.next = tmp;
        if (node1.next == nil) {
            self.last = node1;
        }else{
            node1.next.prev = node1;
        }

        if (node2.next == nil) {
            self.last = node2;
        }else{
            node2.next.prev = node2;
        }
    }
    
    //cui:更新链表
//    LinkedHashMapNode *removeNode = node2;

    LinkedHashMapNode *removeNode = node1;
    if (removeNode == nil) {
        removeNode = node1;
    }
    
    LinkedHashMapNode *prev = removeNode.prev;
    LinkedHashMapNode *next = removeNode.next;

    if (prev == nil) {
        self.first = next;
    }else{
        prev.next = next;
    }
    
    if (next == nil) {
        self.last = prev;
    }else{
        next.prev = prev;
    }
    
}


@end
