//
//  BlockStrongReference.m
//  block底层
//
//  Created by Jane on 2017/6/26.
//  Copyright © 2017年 Jane. All rights reserved.
//

#import "BlockStrongReference.h"
#import <Foundation/Foundation.h>
#import <Block.h>
#import <objc/runtime.h>
#import <dlfcn.h>

#if DEBUG

enum { // Flags from BlockLiteral
    BLOCK_DEALLOCATING =      (0x0001),  // runtime
    BLOCK_REFCOUNT_MASK =     (0xfffe),  // runtime
    BLOCK_NEEDS_FREE =        (1 << 24), // runtime
    BLOCK_HAS_COPY_DISPOSE =  (1 << 25), // compiler
    BLOCK_HAS_CTOR =          (1 << 26), // compiler: helpers have C++ code
    BLOCK_IS_GC =             (1 << 27), // runtime
    BLOCK_IS_GLOBAL =         (1 << 28), // compiler
    BLOCK_USE_STRET =         (1 << 29), // compiler: undefined if !BLOCK_HAS_SIGNATURE
    BLOCK_HAS_SIGNATURE  =    (1 << 30), // compiler
    BLOCK_HAS_EXTENDED_LAYOUT=(1 << 31)  // compiler
};


enum {
    // Byref refcount must use the same bits as Block_layout's refcount.
    // BLOCK_DEALLOCATING =      (0x0001),  // runtime
    // BLOCK_REFCOUNT_MASK =     (0xfffe),  // runtime
    
    BLOCK_BYREF_LAYOUT_MASK =       (0xf << 28), // compiler
    BLOCK_BYREF_LAYOUT_EXTENDED =   (  1 << 28), // compiler
    BLOCK_BYREF_LAYOUT_NON_OBJECT = (  2 << 28), // compiler
    BLOCK_BYREF_LAYOUT_STRONG =     (  3 << 28), // compiler
    BLOCK_BYREF_LAYOUT_WEAK =       (  4 << 28), // compiler
    BLOCK_BYREF_LAYOUT_UNRETAINED = (  5 << 28), // compiler
    
    BLOCK_BYREF_IS_GC =             (  1 << 27), // runtime
    
    BLOCK_BYREF_HAS_COPY_DISPOSE =  (  1 << 25), // compiler
    BLOCK_BYREF_NEEDS_FREE =        (  1 << 24), // runtime
};

//block的结构
struct Block_layout {
    void *isa;
    int flags;
    int reserved;
    void (*invoke)(void *, ...);//block 执行方法
    struct Block_descriptor *descriptor;
    /* Imported variables. */
};

//描述
struct Block_descriptor {
    unsigned long int reserved;
    unsigned long int size;
    void (*copy)(void *dst, void *src);//拷贝
    void (*dispose)(void *);//销毁
};



//剔除1或者0
static void eliminate(char* A, char* tempStorage, unsigned long int size, char c){
    for (unsigned long int i = 0; i < size; i++) {
        if (A[i] != c) {
            tempStorage[i]++;
        }
    }
}

struct __Block_byref_a_head {
    void *__isa;
    struct __Block_byref_a_0 *__forwarding;
    int flags;
    int size;
    void (*copy)(void*, void*);
    void (*dispose)(void*);
};

struct __Block_byref_a_0 {
    struct __Block_byref_a_head head;
    NSObject *a;
};

static NSArray* inspectionBlock(void* block) {
    NSMutableArray* strongs = [[NSMutableArray alloc] init];
    
    struct Block_layout* aBlock = (__bridge struct Block_layout*)block;
    //创建两块空间
    char* result = malloc(aBlock->descriptor->size);
    char* tempStorage = malloc(aBlock->descriptor->size);
    if (tempStorage && result && aBlock->flags & BLOCK_HAS_COPY_DISPOSE) {
        
        //1. 将tempStorage, result中的内容置为0
        memset(result, 0, aBlock->descriptor->size);
        memset(tempStorage, 0, aBlock->descriptor->size);
        (*aBlock->descriptor->copy)(result, aBlock);
        
        eliminate(result, tempStorage, aBlock->descriptor->size, 0);
        (*aBlock->descriptor->dispose)(result);
        
        //2. 将tempStorage, result中的内容置为1
        memset(result, 1, aBlock->descriptor->size);
        (*aBlock->descriptor->copy)(result, aBlock);
        
        eliminate(result, tempStorage, aBlock->descriptor->size, 1);
        //3. 将result销毁
        (*aBlock->descriptor->dispose)(result);
        
        memcpy(result, aBlock, aBlock->descriptor->size);
        
        //5. 将中间改变的数值取出
        //偏移位置,对象
        NSMutableDictionary<NSNumber*, NSObject*>* test = [[NSMutableDictionary alloc] init];
        for (unsigned int i = 0; i < aBlock->descriptor->size; i++) {
            //5.1 tempStorage 中所有非0
            if (tempStorage[i] != 0) {// change from this
                for (unsigned int j = i; j < aBlock->descriptor->size; j++) {
                    if (tempStorage[j] == 0 || (j - i + 1) == sizeof(void*)) {
                        // change form i to j
                        void* p = nil;
                        memcpy(&p, ((char*)aBlock)+i, j-i+1);
                        //Class cls = [p class];
                        
                        struct __Block_byref_a_0* ref = (struct __Block_byref_a_0*)p;
                        if (ref->head.__isa) {
                            NSObject* obj = [[NSObject alloc] init];
                            [test setObject:obj forKey:[NSNumber numberWithInt:i]];
                            [obj release];
                            memcpy(result+i, (void*)&obj, sizeof(void*));
                        } else {// __block
                            int aBLOCK_BYREF_HAS_COPY_DISPOSE = ref->head.flags & BLOCK_BYREF_HAS_COPY_DISPOSE;
                            int aBLOCK_BYREF_LAYOUT_STRONG = ref->head.flags & BLOCK_BYREF_LAYOUT_STRONG;
                            
                            if (aBLOCK_BYREF_HAS_COPY_DISPOSE && aBLOCK_BYREF_LAYOUT_STRONG) {
                                [strongs addObject:[NSArray arrayWithObjects:@(1), @(i), nil]];
                                
                            }
                        }
                        
                        i = j;
                        break;
                    }
                }
            }
        }
        
        NSMutableDictionary<NSNumber*, NSNumber*>* retainCount1 = [[NSMutableDictionary alloc] init];
        for (NSNumber* offset in test.allKeys) {
            NSObject* obj = [test objectForKey:offset];
            [retainCount1 setObject:[NSNumber numberWithInteger:obj.retainCount] forKey:offset];
        }
        memcpy(tempStorage, result, aBlock->descriptor->size);
        (*aBlock->descriptor->copy)(result, tempStorage); // do fixup
        NSMutableDictionary<NSNumber*, NSNumber*>* retainCount2 = [[NSMutableDictionary alloc] init];
        for (NSNumber* offset in test.allKeys) {
            NSObject* obj = [test objectForKey:offset];
            [retainCount2 setObject:[NSNumber numberWithInteger:obj.retainCount] forKey:offset];
        }
        (*aBlock->descriptor->dispose)(result);
        
        for (NSNumber* offset in test.allKeys) {
            NSNumber* a = [retainCount1 objectForKey:offset];
            NSNumber* b = [retainCount2 objectForKey:offset];
            if (![a isEqual:b]) {
                [strongs addObject:[NSArray arrayWithObjects:@(0), offset, nil]];
            }
        }
        
        [retainCount1 release];
        [retainCount2 release];
        [test release];
    }
    if (result)
        free(result);
    if (tempStorage)
        free(tempStorage);
    
    return [strongs autorelease];
}


static NSMutableDictionary* __block_struct = nil;
static Class __mallocBlock = nil;
static Class __stackBlock = nil;

#endif

bool isBlockStrongReference(id block, id check) {
#if DEBUG
    if (__mallocBlock == nil) {
        int ta = 0;
        void (^t)() = ^{
            int b = ta;
            (void)b;
        };
        
        __stackBlock = [t class];
        
        id b = [t copy];
        __mallocBlock = [b class];
        [b release];
    }
    
    if (![block isKindOfClass:__mallocBlock] && ![block isKindOfClass:__stackBlock])
        return NO;
    
    struct Block_layout* aBlock = (__bridge struct Block_layout*)block;
    
    if (aBlock == nil || aBlock->invoke == nil)
        return nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __block_struct = [[NSMutableDictionary alloc] init];
    });
    
    NSArray* __struct = nil;
    @synchronized (__block_struct) {
        __struct = [__block_struct objectForKey:[NSValue valueWithPointer:aBlock->invoke]];
        if (__struct == nil)
        {
            __struct = inspectionBlock(block);
            [__block_struct setObject:__struct forKey:[NSValue valueWithPointer:aBlock->invoke]];
        }
    }
    
    char* temp = (char*)aBlock;
    for (NSArray* a in __struct) {
        BOOL isRef = [[a objectAtIndex:0] boolValue];
        int offset = [[a objectAtIndex:1] intValue];
        
        void* p = nil;
        memcpy(&p, temp+offset, sizeof(void*));
        if (isRef) {
            struct __Block_byref_a_0* ref = (struct __Block_byref_a_0*)p;
            if (ref->head.__forwarding->a == check) {
                return YES;
            }
        } else {
            if (p == check) {
                return YES;
            }
        }
    }
#endif
    return NO;
}




