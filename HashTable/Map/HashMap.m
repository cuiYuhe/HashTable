//
//  HashMap.m
//  HashMap
//
//  Created by cuiyuheMacAir on 2019/9/28.
//  Copyright © 2019年 qinger. All rights reserved.
//

#import "HashMap.h"
#import "HashMapNode.h"

static NSUInteger const DEFAULT_CAPACITY = 1 << 4;
///装填因子 = 节点总数量/哈希表桶数组长度
static float const DEFAULT_Load_Factor = 0.75f;



@interface HashMap()

/// 数组
@property (nonatomic, strong) NSMutableArray<HashMapNode *> *table;

@end

@implementation HashMap

#pragma mark --- 子类实现
- (__kindof HashMapNode *)createNodeWithKey:(id)key value:(nullable id)value parent:(HashMapNode *)parent{
    return [HashMapNode nodeWithKey:key value:value parent:parent];
}

- (void)afterRemove:(__kindof HashMapNode *)willNode removedNode:(__kindof HashMapNode *)removedNode{}


- (instancetype)init{
    if (self = [super init]) {
        [self _initialiseTableWithCapacity:DEFAULT_CAPACITY];
    }
    return self;
}

- (void)setSize:(NSUInteger)size{
    _size = size;
}


- (BOOL)isEmpty{
    return YES;
}

- (BOOL)containsKey:(id)key{
    return [self _nodeOfKey:key] != nil;
}

- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id _Nonnull, id _Nonnull, BOOL * _Nonnull stop))block{
    if (self.size == 0) return;
    
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i=0; i<self.table.count; i++) {
        if (self.table[i] == (id)kCFNull) {
            continue;
        }
        
        [array addObject:self.table[i]];
        do {
            HashMapNode *node = array.firstObject;
            BOOL stop = NO;
            block(node.key, node.value, &stop);
            if (stop) {
                return;
            }
            
            [array removeObjectAtIndex:0];
            if (node.left) {
                [array addObject:node.left];
            }
            
            if (node.right) {
                [array addObject:node.right];
            }
            
        } while (array.count > 0);
    }
}

- (BOOL)containsValue:(id)value{
    if (self.size == 0) return NO;
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i=0; i<self.table.count; i++) {
        if (self.table[i] == (id)kCFNull) {
            continue;
        }
        
        [array addObject:self.table[i]];
        do {
            HashMapNode *node = array.firstObject;
            if ([node.value isEqual:value]) {
                return YES;
            }
            
            [array removeObjectAtIndex:0];
            if (node.left) {
                [array addObject:node.left];
            }
            
            if (node.right) {
                [array addObject:node.right];
            }
            
        } while (array.count > 0);
    }
    
    return NO;
}

- (void)clear{
    if (self.size == 0) {
        return;
    }
    self.size = 0;
    [self.table removeAllObjects];
}

- (id)putWithKey:(id)key value:(id)value{
    NSAssert(key != nil, @"key不能为空");
    
    NSUInteger index = [self _indexOfKey:key];
    HashMapNode *root = self.table[index];
    if (root == (id)kCFNull) { //表明当前index没有保存东西
        root = [self createNodeWithKey:key value:value parent:nil];
        self.table[index] = root;
        self.size++;
        
        [self _afterPut:root];
        return nil;
    }
    
    HashMapNode *parent = root;
    HashMapNode *node = root;
    NSInteger cmp = 0;
    id key1 = key;
    NSUInteger h1 = [self _hashCodeOfKey:key1];
    HashMapNode *result = nil;
    BOOL isSearched = NO;
    do {
        parent = node;
        NSUInteger h2 = node.hashCode;
        id key2 = node.key;
        
        if (h1 > h2) {
            cmp = 1; // 代表传入的hash值大于当前比较的node的hash值,则需要向右扫描
        }else if (h1 < h2){
            cmp = -1;
        }else if ([key1 isEqual:key2]){ //相等,新值替代旧值
            cmp = 0;
        }else if ([key1 class] == [key2 class] &&
                  [key1 respondsToSelector:@selector(compare:)] &&
                  (cmp = [key1 compare:key2]) != NSOrderedSame ){
                //NSOrderedSame 则走其它if. NSOrderedSame时不能认为找到,因为可能不equal
            
        }else if (isSearched){ //如果扫描过,说明没找到.不用再扫描了,直接比较内存地址
            cmp = (NSInteger)key1 - (NSInteger)key2;
            
        }else{ //没有扫描过
            
            //扫描有没有这个key, 没有的话,再根据内存地址,向左走或向右走
            if (
                (node.right != nil && (result = [self _nodeForKey:key1 startNode:node.right])) ||
                (node.left != nil && (result = [self _nodeForKey:key1 startNode:node.left]))
                ) {
                //result有值,找到了node,存在这个key,要覆盖result
                node = result;
                cmp = 0;
            }else{ //不存在这个key, 则根据内存地址,向左走或向右走
                //代表传入的hash值大于当前比较的node的hash值 相等,但是不equal,不可比较
                cmp = (NSInteger)key1 - (NSInteger)key2;
                isSearched = YES;
            }
        }
        
        if (cmp > 0) {
            node = node.right;
        }else if (cmp < 0) {
            node = node.left;
        }else{
            node.key = key;
            id oldValue = node.value;
            node.value = value;
            node.hashCode = h1; //其实这地方可以不写,因为此种情况下node.hashCode就是h1
            return oldValue;
        }
    }while (node);
    
    HashMapNode *newNode = [self createNodeWithKey:key value:value parent:parent];
    if (cmp < 0) {
        parent.left = newNode;
    }else{
        parent.right = newNode;
    }
    self.size++;
    [self _afterPut:newNode];
    
    return nil;
}

- (id)getWithKey:(id)key{
    HashMapNode *node = [self _nodeOfKey:key];
    return node.value;
}

- (id)removeWithKey:(id)key{
    return [self _removeWithNode:[self _nodeOfKey:key]];
}

#pragma mark --- private method
///扩容
- (void)_resize {
    if (1.0*self.size/self.table.count <= DEFAULT_Load_Factor) return;
    NSMutableArray *oldTable = self.table;
    [self _initialiseTableWithCapacity:self.size << 1];
    
    //拿到所有的节点, 再移动到新桶
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i=0; i<oldTable.count; i++) {
        if (oldTable[i] == (id)kCFNull) {
            continue;
        }
        [array addObject:oldTable[i]];
        do {
            HashMapNode *node = array.firstObject;
            [array removeObjectAtIndex:0];
            if (node.left) {
                [array addObject:node.left];
            }
            
            if (node.right) {
                [array addObject:node.right];
            }
            
            [self _moveNodeToNewTable:node];
        } while (array.count > 0);
    }
}

///扩容时将节点移到新桶
- (void)_moveNodeToNewTable:(HashMapNode *)newNode{
    //重置
    newNode.parent = nil;
    newNode.left = nil;
    newNode.right = nil;
    newNode.color = RED;
    
    NSUInteger index = [self _indexOfNode:newNode];
    HashMapNode *root = self.table[index];
    if (root == (id)kCFNull) { //表明当前index没有保存东西
        root = newNode;
        self.table[index] = root;
        [self _afterPut:root];
        return;
    }
    
    //因为是移动,node之间肯定不相同.
    HashMapNode *parent = root;
    HashMapNode *node = root;
    NSInteger cmp = 0;
    id key1 = newNode.key;
    NSUInteger h1 = newNode.hashCode;
    do {
        parent = node;
        NSUInteger h2 = node.hashCode;
        id key2 = node.key;
        
        if (h1 > h2) {
            cmp = 1; // 代表传入的hash值大于当前比较的node的hash值,则需要向右扫描
        }else if (h1 < h2){
            cmp = -1;
        }else if ([key1 class] == [key2 class] &&
                  [key1 respondsToSelector:@selector(compare:)] &&
                  (cmp = [key1 compare:key2]) != NSOrderedSame ){
            //NSOrderedSame 则走其它if. NSOrderedSame时不能认为找到,因为可能不equal
            
        }else{ //如果扫描过,说明没找到.不用再扫描了,直接比较内存地址
            cmp = (NSInteger)key1 - (NSInteger)key2;
        }
        
        if (cmp > 0) {
            node = node.right;
        }else if (cmp < 0) {
            node = node.left;
        }
    }while (node);
    
    if (cmp < 0) {
        parent.left = newNode;
    }else{
        parent.right = newNode;
    }
    newNode.parent = parent;
    [self _afterPut:newNode];
}

- (void)_initialiseTableWithCapacity:(NSUInteger)capacity{
    self.table = [NSMutableArray arrayWithCapacity:capacity];
    for (int i=0; i<capacity; i++) {
        //初始化,node的key与value都是nil
        [self.table addObject:(id)kCFNull];
    }

}

- (id)_removeWithNode:(HashMapNode *)node {
    if (!node) { return nil; }
    
    HashMapNode *willNode = node;
    self.size--;
    id oldValue = node.value;
    
    if (node.isTwoDegrees) { //度为2
        //找到后继节点代替root
        HashMapNode *suc = [self successorNodeOfNode:node];
        node.key = suc.key;
        node.value = suc.value;
        node.hashCode = suc.hashCode;
        node = suc;// 删除后继节点,即删除node.
    }
    //替换node的节点
    HashMapNode *replaceNode = node.left ? : node.right;
    NSUInteger index = [self _indexOfNode:node];
    if (replaceNode) { // 度为1
        replaceNode.parent = node.parent;
        
        if (node.parent == nil) {
            self.table[index] = replaceNode;
        }else if (node == node.parent.left) {
            node.parent.left = replaceNode;
        }else{
            node.parent.right = replaceNode;
        }
        
        //删除的节点是replaceNode
        [self fixAfterRemove:node replaceNode:replaceNode];
        
    }else { //度为0: node是叶子节点
        if (node.parent == nil) { //node是叶子节点,也是root
            self.table[index] = [self createNodeWithKey:nil value:nil parent:nil];
        }else{
            if (node == node.parent.left) {
                node.parent.left = nil;
            }else if (node == node.parent.right) {
                node.parent.right = nil;
            }
            [self fixAfterRemove:node replaceNode:nil];
        }
    }
    
    //交给子类处理
    [self afterRemove:willNode removedNode:node];
    return oldValue;
}

/**
 根据key生成对应的索引
 */
- (NSUInteger)_indexOfKey:(id)key {
    return [self _hashCodeOfKey:key] & (self.table.count - 1);
}

- (NSUInteger)_hashCodeOfKey:(id)key{
    NSUInteger hash = [key hash];
    // 扰动计算
    return hash ^ (hash >> 16);
}

- (NSUInteger)_indexOfNode:(HashMapNode *)node{
    return node.hashCode & (self.table.count - 1);
}

- (void)_afterPut:(__kindof HashMapNode *)node{
    /**
     添加的默认节点为RED,这样只需要处理下面的特点(其它特点都符合):
     4. RED 节点的子节点都是 BLACK
     4.1 RED 节点的 parent 都是 BLACK
     4.2 从根节点到 叶子节点 的所有 路径上不能2 个连续的 RED 节点
     
     添加一共有12种情况:
     1.父节点为黑色,有4种情况,不需要处理
     2.父节点为红色,有8种情况,需要处理
     */
    HashMapNode *parent = node.parent;
    
    if (parent == nil) {
        [self _colorWithNode:node color:BLACK]; //根节点为黑色
        return;
    }
    
    if ([self _isBlackOfNode:parent]) {
        return;
    }
    
    /*
     下面是父节点是红色节点的情况,此时又分成两种情况:添加节点的叔父节点是不是红色,
     */
    HashMapNode *uncle = node.parent.siblingNode;
    
    // 红色节点: 1.新添加的节点 2.旋转后变成了子节点(不是根节点)
    HashMapNode *grand = [self _redWithNode:(HashMapNode *)parent.parent];
    
    if ([self _isRedOfNode:uncle]) {// 叔父节点是红色【B树节点上溢】,已经4个节点
        [self _blackWithNode:parent];
        [self _blackWithNode:uncle];
        
        [self _afterPut:grand];
        return;
    }
    
    //叔父节点不是红色
    if (parent.isLeftChild) { //L
        if (node.isLeftChild) {//LL
            [self _blackWithNode:parent];
        }else{//LR
            [self _blackWithNode:node];
            [self _rotateLeft:parent];
        }
        [self _rotateRight:grand];
        
    }else{ //R
        if (node.isLeftChild) {//RL
            [self _blackWithNode:node];
            [self _rotateRight:parent];
        }else{//RR
            [self _blackWithNode:parent];
        }
        [self _rotateLeft:grand];
    }
}


///染成红色
- (HashMapNode *)_redWithNode:(HashMapNode *)node{
    return [self _colorWithNode:node color:RED];
}

///染成黑色
- (HashMapNode *)_blackWithNode:(HashMapNode *)node{
    return [self _colorWithNode:node color:BLACK];
}

///染色
- (HashMapNode *)_colorWithNode:(HashMapNode *)node color:(BOOL)color{
    HashMapNode *rbNode = (HashMapNode *)node;
    rbNode.color = color;
    return node;
}

- (BOOL)_isBlackOfNode:(HashMapNode *)node{
    return [self _colorOfNode:node] == BLACK;
}

- (BOOL)_isRedOfNode:(HashMapNode *)node{
    return [self _colorOfNode:node] == RED;
}

- (BOOL)_colorOfNode:(HashMapNode *)node{
    HashMapNode *rbNode = (HashMapNode *)node;
    return node == nil ? BLACK : rbNode.color;
}

/**
 左旋不平衡的祖父节点,当RR时。RR是指添加分支的节点相对于祖父节点来说的方向是：RR（右右）
 @param grand 祖父节点
 */
- (void)_rotateLeft:(HashMapNode *)grand{
    HashMapNode *parent = grand.right;
    HashMapNode *child = parent.left;
    grand.right = child;
    parent.left = grand;
    [self _afterRotate:grand parent:parent child:child];
}

/**
 右旋不平衡的祖父节点,当LL时。LL是指添加分支的节点相对于祖父节点来说的方向是：LL（左左）
 @param grand 祖父节点
 */
- (void)_rotateRight:(HashMapNode *)grand{
    HashMapNode *parent = grand.left;
    HashMapNode *child = parent.right;
    parent.right = grand;
    grand.left = child;
    [self _afterRotate:grand parent:parent child:child];
}

/**
 旋转祖先节点后的操作：
 1）需要更新祖先节点grand、父节点_parent、子节点_child 的父节点
 2）更新grand、parent的高度height
 
 @param grand 旋转的祖先节点
 @param parent 父节点
 @param child 最下面的节点
 */
- (void)_afterRotate:(HashMapNode *)grand parent:(HashMapNode *)parent child:(HashMapNode *)child{
    //parent是grand的父节点了
    parent.parent = grand.parent;
    //更新再上一层节点的子节点
    if (grand.isLeftChild) {
        grand.parent.left = parent;
    }else if (grand.isRightChild) {
        grand.parent.right = parent;
    }else{
        // 设置根节点为parent
        self.table[[self _indexOfNode:grand]] = parent;
    }
    grand.parent = parent;
    child.parent = grand;
    
    //更新高度
    //    [self _updateNode:parent];
    //    [self _updateNode:grand];
}


/**
 两个key比较

 @param k1 key
 @param k2 key
 @param h1 k1的hash值
 @param h2 k2的hash值
 @return 如果k1<k2,升序小于0; 如果k1>k2,降序大于0; 相等==0;
 */
//- (NSInteger)_compare:(_Nonnull id)k1 k2:(_Nonnull id)k2 hash1:(NSUInteger)h1 hash2:(NSUInteger)h2 {
//    
//    NSInteger result = h1 - h2;
//    if (result != 0) {
//        return result;
//    }
//    
//    // 是同类型
//    if ([k1 respondsToSelector:@selector(compare:)]) {
//        return [k1 compare:k2];
//    }else{
//        return (NSInteger)k1 - (NSInteger)k2;
//    }
//}

///找到key对应的node
- (HashMapNode *)_nodeOfKey:(id)key{
    NSUInteger index = [self _indexOfKey:key];
    HashMapNode *root = self.table[index];
    return root == (id)kCFNull ? nil : [self _nodeForKey:key startNode:root];
}


/**
 从node开始查找key1的node,扫描递归查找
 
 @param key1 找这个key的node
 @param node 从这个node开始查找
 @return key1的node
 */
- (HashMapNode *)_nodeForKey:(id)key1 startNode:(HashMapNode *)node{
    NSUInteger h1 = [self _hashCodeOfKey:key1];
    
    HashMapNode *result = nil;
    NSComparisonResult cmp = NSOrderedSame;
    while (node) {
        // 保证h1与h2的计算方式一致,此处都经过了扰动计算
        NSUInteger h2 = node.hashCode;
        id key2 = node.key;

        if (h1 > h2) {
            node = node.right;
        }else if (h1 < h2) {
            node = node.left;
        }else if ([key1 isEqual:key2]) {
            return node;
        }else if (
                  [key1 class] == [key2 class] &&
                  [key1 respondsToSelector:@selector(compare:)] &&
                  (cmp = [key1 compare:key2]) != NSOrderedSame
                  ) {
            NSComparisonResult cmp = [key1 compare:key2];
            node = cmp > 1 ? node.right : node.left;

        }else{ //hash相等,没有可比较性,不equal
            //递归左右结点查找
            if (node.right && (result = [self _nodeForKey:key1 startNode:node.right])) {
                // result有值代表查找到,直接返回; 没值则直接递归,不会来到这里
                return result;
            }else{
                //没有右边,就只能走左边这一个可能, 所以可以直接用左节点,省略递归
                node = node.left;
            }
//            }else if (node.left && (result = [self _nodeForKey:key1 startNode:node.left])) {
//                // result有值代表查找到,直接返回; 没值则直接递归,不会来到这里
//                return result;
//            }else{
//                return nil;
//            }
        }
    }
    return node;
}

///后驱节点:中序遍历时的后一个节点
- (HashMapNode *)successorNodeOfNode:(HashMapNode *)node{
    if (!node) {return nil;}
    
    HashMapNode *target = node.right;
    if (target) { //有右子树, 则在右子树的最左的节点
        while (target.left) {
            target = target.left;
        }
        return target;
    }
    
    // 没有右子树 ,则从父节点找
    target = node;
    while (target.parent && target == target.parent.right) {
        target = target.parent;
    }
    
    //来到这里,表明:1.parent为空 2.target不是其父节点的右节点
    return target.parent;
}

- (void)fixAfterRemove:(__kindof HashMapNode *)node replaceNode:(__kindof HashMapNode *)replaceNode{
    /*
     最后实际删除的点,即清理内存的节点是叶子节点.
     传进来的node,即为实际删除的节点,
     如果删除的节点是红色; 或者替代的节点是红色
     */
    if ([self _isRedOfNode:node]) { //删除的红色节点
        return;
    }
    
    if ([self _isRedOfNode:replaceNode]) { //替代的节点是红色节点
        [self _blackWithNode:replaceNode];
        return;
    }
    HashMapNode *parent = (HashMapNode *)node.parent;
    if (parent == nil) { //删除的是根结点
        return;
    }
    
    //删除的是黑色叶子节点,即下溢
    /*
     判断被删除的节点是左还是右
     1.当父类调用时,父节点会将这个node清除,所以用父节点的哪边为空判断
     2.当自身递归调用时,父节点的左指针未清空
     */
    BOOL isLeft = parent.left == nil || node.isLeftChild;
    HashMapNode *sibling = isLeft ? parent.right : parent.left;
    
    //注:下面两种情况的代码是对称的
    if (isLeft) {//被删除的节点在左边
        if ([self _isRedOfNode:sibling]) {
            [self _blackWithNode:sibling];
            [self _redWithNode:parent];
            [self rotateLeft:parent];
            
            //更换兄弟
            sibling = parent.right;
        }
        
        //兄弟节点是黑色
        BOOL isLeftRed = [self _isRedOfNode:sibling.left];
        BOOL isRightRed = [self _isRedOfNode:sibling.right];
        if (isLeftRed || isRightRed) { //至少有一个红色节点
            
            if ([self _isBlackOfNode:sibling.right]){
                //兄弟节点是黑色,左旋转. 旋转后就是LL的情况
                [self rotateRight:sibling];
                sibling = parent.right; //旋转后,兄弟节点改变
            }
            
            [self _colorWithNode:sibling color:[self _colorOfNode:parent]];
            [self _blackWithNode:sibling.right];
            [self _blackWithNode:parent];
            [self rotateLeft:parent];
            
            
        }else{ //没有红色节点
            BOOL isParentBlack = [self _isBlackOfNode:node.parent];
            [self _blackWithNode:parent];
            [self _redWithNode:sibling];
            if (isParentBlack) {
                [self fixAfterRemove:parent replaceNode:nil];
            }
        }
        
    }else{ //被删除的节点在右边
        if ([self _isRedOfNode:sibling]) {
            [self _blackWithNode:sibling];
            [self _redWithNode:parent];
            [self rotateRight:parent];
            
            //更换兄弟
            sibling = parent.left;
        }
        
        //兄弟节点是黑色
        BOOL isLeftRed = [self _isRedOfNode:sibling.left];
        BOOL isRightRed = [self _isRedOfNode:sibling.right];
        if (isLeftRed || isRightRed) { //至少有一个红色节点
            
            if ([self _isBlackOfNode:sibling.left]){
                //兄弟节点是黑色,左旋转. 旋转后就是LL的情况
                [self rotateLeft:sibling];
                sibling = parent.left; //旋转后,兄弟节点改变
            }
            
            [self _colorWithNode:sibling color:[self _colorOfNode:parent]];
            [self _blackWithNode:sibling.left];
            [self _blackWithNode:parent];
            [self rotateRight:parent];
            
        }else{ //没有红色节点
            BOOL isParentBlack = [self _isBlackOfNode:node.parent];
            [self _blackWithNode:parent];
            [self _redWithNode:sibling];
            if (isParentBlack) {
                [self fixAfterRemove:parent replaceNode:nil];
            }
        }
    }
}

/**
 左旋不平衡的祖父节点,当RR时。RR是指添加分支的节点相对于祖父节点来说的方向是：RR（右右）
 @param grand 祖父节点
 */
- (void)rotateLeft:(HashMapNode *)grand{
    HashMapNode *parent = grand.right;
    HashMapNode *child = parent.left;
    grand.right = child;
    parent.left = grand;
    [self afterRotate:grand parent:parent child:child];
}

/**
 右旋不平衡的祖父节点,当LL时。LL是指添加分支的节点相对于祖父节点来说的方向是：LL（左左）
 @param grand 祖父节点
 */
- (void)rotateRight:(HashMapNode *)grand{
    HashMapNode *parent = grand.left;
    HashMapNode *child = parent.right;
    parent.right = grand;
    grand.left = child;
    [self afterRotate:grand parent:parent child:child];
}

/**
 旋转祖先节点后的操作：
 1）需要更新祖先节点grand、父节点_parent、子节点_child 的父节点
 2）更新grand、parent的高度height
 
 @param grand 旋转的祖先节点
 @param parent 父节点
 @param child 最下面的节点
 */
- (void)afterRotate:(HashMapNode *)grand parent:(HashMapNode *)parent child:(HashMapNode *)child{
    //parent是grand的父节点了
    parent.parent = grand.parent;
    NSUInteger index = [self _indexOfNode:grand];
    //更新再上一层节点的子节点
    if (grand.isLeftChild) {
        grand.parent.left = parent;
    }else if (grand.isRightChild) {
        grand.parent.right = parent;
    }else{ //原来grand是root
        self.table[index] = parent;
    }
    grand.parent = parent;
    child.parent = grand;
    
    //更新高度
    //    [self _updateNode:parent];
    //    [self _updateNode:grand];
}

@end
