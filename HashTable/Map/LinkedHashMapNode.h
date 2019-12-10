//
//  LinkedHashMapNode.h
//  HashTable
//
//  Created by cuiyuheMacAir on 2019/11/4.
//  Copyright © 2019年 qinger. All rights reserved.
//

#import "HashMapNode.h"


@interface LinkedHashMapNode : HashMapNode

@property (nonatomic, strong) LinkedHashMapNode *prev;
@property (nonatomic, strong) LinkedHashMapNode *next;
@end

