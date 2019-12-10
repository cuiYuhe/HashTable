//
//  LinkedHashMap.h
//  HashTable
//
//  Created by cuiyuheMacAir on 2019/11/4.
//  Copyright © 2019年 qinger. All rights reserved.
//

#import "HashMap.h"
@class LinkedHashMapNode;

@interface LinkedHashMap : HashMap

/// 第一个节点
@property (nonatomic, strong) LinkedHashMapNode *first;
/// 最后的节点
@property (nonatomic, strong) LinkedHashMapNode *last;

@end

