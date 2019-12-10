//
//  TreeMap.m
//  HashMap
//
//  Created by cuiyuheMacAir on 2019/9/28.
//  Copyright © 2019年 qinger. All rights reserved.
//

#import "TreeMap.h"
#import "YHCompareProtocol.h"

static BOOL const RED = NO;
static BOOL const BLACK = YES;

@interface TreeMapNode : NSObject
@property (nonatomic, strong) id<YHCompareProtocol> key;
@property (nonatomic, strong) id value;
@property (nonatomic, strong) TreeMapNode *parent;
/// 左节点
@property (nonatomic, strong) TreeMapNode *left;
/// 右节点
@property (nonatomic, strong) TreeMapNode *right;
/// 兄弟节点
@property (nonatomic, strong, readonly) TreeMapNode *siblingNode;
/// 是否叶子节点
@property (nonatomic, assign, readonly) BOOL isLeaf;
/// 是否度为2
@property (nonatomic, assign, readonly) BOOL isTwoDegrees;
@property (nonatomic, assign, readonly) BOOL isLeftChild;
@property (nonatomic, assign, readonly) BOOL isRightChild;
/// 当前节点颜色
@property (nonatomic, assign) BOOL color;

@end

@implementation TreeMapNode

+ (TreeMapNode *)nodeWithKey:(id<YHCompareProtocol>)key value:(id)value parent:(TreeMapNode *)parent{
    TreeMapNode *node = [[self alloc] init];
    node.key = key;
    node.value = value;
    node.parent = parent;
    node.color = RED;
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
- (TreeMapNode *)sibling{
    if ([self isLeftChild]) {
        return self.parent.right;
    }else if([self isRightChild]){
        return self.parent.left;
    }
    return nil;
}

@end

@interface TreeMap()

/// 根节点
@property (nonatomic, strong) TreeMapNode *root;
@property (nonatomic, assign) NSUInteger size;

@end

@implementation TreeMap

- (NSUInteger)size {
    return _size;
}

- (BOOL)isEmpty {
    return _size == 0;
}

- (void)clear {
    self.root = nil;
    self.size = 0;
}

/// 返回被替代的值
- (id)put:(id)key value:(id)value {
    [self checkNullElement:key];
    
    TreeMapNode *node = self.root;
    TreeMapNode *parent = self.root;
    BOOL isLeft = YES;
    
    TreeMapNode *newNode = nil;
    if (self.size == 0) {
        newNode = [TreeMapNode nodeWithKey:key value:value parent:node];
        self.root = newNode;
    }else{
        
        while (node) {
            parent = node;
            if ([key compare:node.key] == NSOrderedDescending) {
                node = node.right;
                isLeft = NO;
            }else if ([key compare:node.key] == NSOrderedAscending){
                node = node.left;
                isLeft = YES;
            }else{ //相等,新值替代旧值
                node.key = key;
                id oldValue = node.value;
                node.value = value;
                return oldValue;
            }
        }
        
        newNode = [TreeMapNode nodeWithKey:key value:value parent:node];
        if (isLeft) {
            parent.left = newNode;
        }else{
            parent.right = newNode;
        }
    }
    
    self.size++;
    [self afterPut:newNode];
    return nil;
}

/// 外界调用删除元素,外界不知道节点的存在
- (void)remove:(id)key {
    if (!key) return;
    [self _remove:[self _fetchNodeOfKey:key]];
}

- (void)_remove:(TreeMapNode *)node {
    if (!node) { return; }
    
    self.size--;
    if (node.isTwoDegrees) { //度为2
        //找到后继节点代替root
        TreeMapNode *suc = [self successorNodeOfNode:node];
        node.key = suc.key;
        node = suc;// 删除后继节点,即删除node.
    }
    //替换node的节点
    TreeMapNode *replaceNode = node.left ? : node.right;
    if (replaceNode) { // 度为1
        replaceNode.parent = node.parent;
        
        if (node.parent == nil) {
            self.root = replaceNode;
        }else if (node == node.parent.left) {
            node.parent.left = replaceNode;
        }else{
            node.parent.right = replaceNode;
        }
        
        //删除的节点是replaceNode
        [self afterRemove:node replaceNode:replaceNode];
        
    }else { //度为0: node是叶子节点
        if (node.parent == nil) { //node是叶子节点,也是root
            self.root = nil;
        }else{
            if (node == node.parent.left) {
                node.parent.left = nil;
            }else if (node == node.parent.right) {
                node.parent.right = nil;
            }
        }
        
        [self afterRemove:node replaceNode:nil];
    }
}


///前驱节点:中序遍历时的前一个节点
- (TreeMapNode *)predecessorNodeOfNode:(TreeMapNode *)node{
    if (!node) {return nil;}
    
    TreeMapNode *target = node.left;
    if (target) { //有左子树,则前驱节点在左子树中 的最右节点
        while (target.right) {
            target = target.right;
        }
        return target;
    }
    
    //左子树为空,则从父节点找
    target = node;
    while (target.parent && target == target.parent.left) {
        target = target.parent;
    }
    
    //来到这里,表明:1.parent为空 2.target不是其父节点的左节点
    return target.parent;
}

///后驱节点:中序遍历时的后一个节点
- (TreeMapNode *)successorNodeOfNode:(TreeMapNode *)node{
    if (!node) {return nil;}
    
    TreeMapNode *target = node.right;
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

///得到元素的节点
- (TreeMapNode *)_fetchNodeOfKey:(id)key{
    if (!key) return nil;
    
    TreeMapNode *node = self.root;
    while (node) {
        NSComparisonResult result = [node.key compare:key];
        if (result == NSOrderedSame) {
            return node;
        }else if (result == NSOrderedAscending) {//升序
            node = node.right;
        }else{
            node = node.left;
        }
    }
    return nil;
}

- (BOOL)contains:(id)anObject {
    return [self _fetchNodeOfKey:anObject] != nil;
}

- (void)afterPut:(__kindof TreeMapNode *)node{
    /**
     添加的默认节点为RED,这样只需要处理下面的特点(其它特点都符合):
     4. RED 节点的子节点都是 BLACK
     4.1 RED 节点的 parent 都是 BLACK
     4.2 从根节点到 叶子节点 的所有 路径上不能2 个连续的 RED 节点
     
     添加一共有12种情况:
     1.父节点为黑色,有4种情况,不需要处理
     2.父节点为红色,有8种情况,需要处理
     */
    TreeMapNode *parent = node.parent;
    
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
    TreeMapNode *uncle = node.parent.siblingNode;
    
    // 红色节点: 1.新添加的节点 2.旋转后变成了子节点(不是根节点)
    TreeMapNode *grand = [self _redWithNode:(TreeMapNode *)parent.parent];
    
    if ([self _isRedOfNode:uncle]) {// 叔父节点是红色【B树节点上溢】,已经4个节点
        [self _blackWithNode:parent];
        [self _blackWithNode:uncle];
        
        [self afterPut:grand];
        return;
    }
    
    //叔父节点不是红色
    if (parent.isLeftChild) { //L
        if (node.isLeftChild) {//LL
            [self _blackWithNode:parent];
        }else{//LR
            [self _blackWithNode:node];
            [self rotateLeft:parent];
        }
        [self rotateRight:grand];
        
    }else{ //R
        if (node.isLeftChild) {//RL
            [self _blackWithNode:node];
            [self rotateRight:parent];
        }else{//RR
            [self _blackWithNode:parent];
        }
        [self rotateLeft:grand];
    }
}

- (void)afterRemove:(__kindof TreeMapNode *)node replaceNode:(__kindof TreeMapNode *)replaceNode{
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
    TreeMapNode *parent = (TreeMapNode *)node.parent;
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
    TreeMapNode *sibling = isLeft ? parent.right : parent.left;
    
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
                [self afterRemove:parent replaceNode:nil];
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
                [self afterRemove:parent replaceNode:nil];
            }
        }
    }
}



#pragma mark --- private
/**
 左旋不平衡的祖父节点,当RR时。RR是指添加分支的节点相对于祖父节点来说的方向是：RR（右右）
 @param grand 祖父节点
 */
- (void)rotateLeft:(TreeMapNode *)grand{
    TreeMapNode *parent = grand.right;
    TreeMapNode *child = parent.left;
    grand.right = child;
    parent.left = grand;
    [self afterRotate:grand parent:parent child:child];
}

/**
 右旋不平衡的祖父节点,当LL时。LL是指添加分支的节点相对于祖父节点来说的方向是：LL（左左）
 @param grand 祖父节点
 */
- (void)rotateRight:(TreeMapNode *)grand{
    TreeMapNode *parent = grand.left;
    TreeMapNode *child = parent.right;
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
- (void)afterRotate:(TreeMapNode *)grand parent:(TreeMapNode *)parent child:(TreeMapNode *)child{
    //parent是grand的父节点了
    parent.parent = grand.parent;
    //更新再上一层节点的子节点
    if (grand.isLeftChild) {
        grand.parent.left = parent;
    }else if (grand.isRightChild) {
        grand.parent.right = parent;
    }else{ //原来grand是root
        self.root = parent;
    }
    grand.parent = parent;
    child.parent = grand;
    
    //更新高度
    //    [self _updateNode:parent];
    //    [self _updateNode:grand];
}


///染成红色
- (TreeMapNode *)_redWithNode:(TreeMapNode *)node{
    return [self _colorWithNode:node color:RED];
}

///染成黑色
- (TreeMapNode *)_blackWithNode:(TreeMapNode *)node{
    return [self _colorWithNode:node color:BLACK];
}

///染色
- (TreeMapNode *)_colorWithNode:(TreeMapNode *)node color:(BOOL)color{
    TreeMapNode *rbNode = (TreeMapNode *)node;
    rbNode.color = color;
    return node;
}

- (BOOL)_isBlackOfNode:(TreeMapNode *)node{
    return [self _colorOfNode:node] == BLACK;
}

- (BOOL)_isRedOfNode:(TreeMapNode *)node{
    return [self _colorOfNode:node] == RED;
}

- (BOOL)_colorOfNode:(TreeMapNode *)node{
    TreeMapNode *rbNode = (TreeMapNode *)node;
    return node == nil ? BLACK : rbNode.color;
}

- (void)checkNullElement:(id)element {
    NSAssert(element != nil, @"添加值不能为空!");
}
@end
