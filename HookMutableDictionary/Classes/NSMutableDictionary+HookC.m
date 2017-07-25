//
//  NSMutableDictionary+HookC.m
//  Pods
//
//  Created by may on 2017/7/20.
//
//

#import "NSMutableDictionary+HookC.h"
#import <objc/runtime.h>
#import "BlockStrongReference.h"

static NSMutableDictionary *avoidRepeatCallDictionary;
@interface NSMutableDictionary (Private)
@property(nonatomic,strong)NSMutableArray * observers;
@end

@implementation NSMutableDictionary (Private)
@dynamic observers;

- (void)setObservers:(NSMutableArray *)observers {
    objc_setAssociatedObject(self, @selector(observers), observers, OBJC_ASSOCIATION_RETAIN);
}
- (NSMutableArray *)observers {
    id obj = objc_getAssociatedObject(self, @selector(observers));
    if (!obj) {
        obj = [NSMutableArray array];
        objc_setAssociatedObject(self, @selector(observers), obj, OBJC_ASSOCIATION_RETAIN);
    }
    return obj;
}

@end

static NSInteger inCall() {
    @synchronized (avoidRepeatCallDictionary) {
        if (!avoidRepeatCallDictionary) {
            avoidRepeatCallDictionary = [NSMutableDictionary dictionary];
        }
        NSInteger number = [[avoidRepeatCallDictionary objectForKey:[NSValue valueWithPointer:(__bridge const void * _Nullable)([NSThread currentThread])]] integerValue];
        number++;
        [avoidRepeatCallDictionary setObject:@(number) forKey:[NSValue valueWithPointer:(__bridge const void * _Nullable)([NSThread currentThread])]];
        return number;
    }
}

static void outCall() {
    @synchronized (avoidRepeatCallDictionary) {
        NSInteger number = [[avoidRepeatCallDictionary objectForKey:[NSValue valueWithPointer:(__bridge const void * _Nullable)([NSThread currentThread])]] integerValue];
        number--;
        [avoidRepeatCallDictionary setObject:@(number) forKey:[NSValue valueWithPointer:(__bridge const void * _Nullable)([NSThread currentThread])]];
    }
}

#pragma mark 添加

typedef void (*setObjectForKey_IMP)(id self,SEL _cmd,  id object,id key);
static setObjectForKey_IMP origin_setObjectForKey = nil;
static void replace_setObjectForKey (id self, SEL _cmd, id object, id key) {
    NSMutableDictionary *dictionary = self;
    if (dictionary.observers.count) {
        NSInteger number = inCall();
        origin_setObjectForKey(self,_cmd,object,key);
        if (number == 1) {
            for (MutableDictionaryObserver  * server in dictionary.observers) {
                if (server.setObject) {
                    server.setObject(self, object, key);
                }
            }
        }
        outCall();
    } else {
        origin_setObjectForKey(self,_cmd,object,key);
    }
}

typedef void (*setObjectForKeyedSubscript_IMP)(id self,SEL _cmd,  id object,id key);
static setObjectForKeyedSubscript_IMP origin_setObjectForKeyedSubscript = nil;
static void replace_setObjectForKeyedSubscript_IMP (id self, SEL _cmd, id object, id key) {
    NSMutableDictionary *dictionary = self;
    if (dictionary.observers.count) {
        NSInteger number = inCall();
        origin_setObjectForKeyedSubscript(self,_cmd,object,key);
        if (number == 1) {
            for (MutableDictionaryObserver  * server in dictionary.observers) {
                if (server.setObject) {
                    server.setObject(self, object, key);
                }
            }
        }
        outCall();
    } else {
        origin_setObjectForKeyedSubscript(self,_cmd,object,key);
    }
}

typedef void (*setValueForKey_IMP)(id self,SEL _cmd,  id object,id key);
static setValueForKey_IMP origin_setValueForKey = nil;
static void replace_setValueForKey (id self, SEL _cmd, id object, id key) {
    NSMutableDictionary *dictionary = self;
    if (dictionary.observers.count) {
        NSInteger number = inCall();
        origin_setValueForKey(self,_cmd,object,key);
        if (number == 1) {
            for (MutableDictionaryObserver  * server in dictionary.observers) {
                if (server.setObject) {
                    server.setObject(self, object, key);
                }
            }
        }
        outCall();
    } else {
        origin_setValueForKey(self,_cmd,object,key);
    }
}

typedef void (*addEntriesFormDictionary_IMP)(id self,SEL _cmd, NSDictionary *dictionary);
static addEntriesFormDictionary_IMP origin_addEntriesFormDictionary = nil;
static void replace_addEntriesFormDictionary (id self,SEL _cmd,NSDictionary *dictionary) {
    NSMutableDictionary *dic = self;
    if (dic.observers.count) {
        NSInteger number = inCall();
        origin_addEntriesFormDictionary(self,_cmd,dictionary);
        if (number == 1) {
            for (MutableDictionaryObserver  * server in dic.observers) {
                if (server.setDictionary) {
                    server.setDictionary(self);
                }
            }
        }
        outCall();
    } else {
        origin_addEntriesFormDictionary(self,_cmd,dictionary);
    }
}

typedef void (*setDictionary_IMP)(id self,SEL _cmd, NSDictionary *dictionary);
static setDictionary_IMP origin_setDictionary = nil;
static void replace_setDitionary (id self,SEL _cmd,NSDictionary *dictionary) {
    NSMutableDictionary *dic = self;
    if (dic.observers.count) {
        NSInteger number = inCall();
        origin_setDictionary(self,_cmd,dictionary);
        if (number == 1) {
            for (MutableDictionaryObserver  * server in dic.observers) {
                if (server.setDictionary) {
                    server.setDictionary(self);
                }
            }
        }
        outCall();
    } else {
        origin_setDictionary(self,_cmd,dictionary);
    }
}

#pragma mark 删除

typedef void (*removeObjectForKey_IMP)(id self,SEL _cmd, id key);
static removeObjectForKey_IMP origin_removeObjectForKey = nil;
static void replace_removeObjectForKey (id self,SEL _cmd,id key) {
    NSMutableDictionary *dic = self;
    if (dic.observers.count) {
        NSInteger number = inCall();
        origin_removeObjectForKey(self,_cmd,key);
        if (number == 1) {
            for (MutableDictionaryObserver  * server in dic.observers) {
                if (server.removeObjects) {
                    server.removeObjects(self, @[key]);
                }
            }
        }
        outCall();
    } else {
        origin_removeObjectForKey(self,_cmd,@[key]);
    }
}

typedef void (*removeAllObjects_IMP)(id self,SEL _cmd);
static removeAllObjects_IMP origin_removeAllObjects = nil;
static void replace_removeAllObjects (id self,SEL _cmd) {
    NSMutableDictionary *dic = self;
    if (dic.observers.count) {
        NSInteger number = inCall();
        NSArray * keysArray = [NSArray arrayWithArray:dic.allKeys];
        origin_removeAllObjects(self,_cmd);
        if (number == 1) {
            for (MutableDictionaryObserver  * server in dic.observers) {
                if (server.removeObjects) {
                    server.removeObjects(self, keysArray);
                }
            }
        }
        outCall();
    } else {
        origin_removeAllObjects(self,_cmd);
    }
}

typedef void (*removeObjectsForKeys_IMP)(id self,SEL _cmd, NSArray *keys);
static removeObjectsForKeys_IMP origin_removeObjectsForKeys = nil;
static void replace_removeObjectsForKeys (id self,SEL _cmd,NSArray *keys) {
    NSMutableDictionary *dic = self;
    if (dic.observers.count) {
        NSInteger number = inCall();
        origin_removeObjectsForKeys(self,_cmd,keys);
        if (number == 1) {
            for (MutableDictionaryObserver  * server in dic.observers) {
                if (server.removeObjects) {
                    server.removeObjects(self, keys);
                }
            }
        }
        outCall();
    } else {
        origin_removeObjectsForKeys(self,_cmd,keys);
    }
}

@implementation NSMutableDictionary (HookC)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method method;
        Class  class = NSClassFromString(@"__NSDictionaryM");
        method = class_getInstanceMethod(class, @selector(setObject:forKey:));
        origin_setObjectForKey = (setObjectForKey_IMP)method_setImplementation(method, (IMP)replace_setObjectForKey);
        
        method = class_getInstanceMethod(class, @selector(setObject:forKeyedSubscript:));
        origin_setObjectForKeyedSubscript = (setObjectForKeyedSubscript_IMP)method_setImplementation(method, (IMP)replace_setObjectForKeyedSubscript_IMP);
        
        method = class_getInstanceMethod(class, @selector(setValue:forKey:));
        origin_setValueForKey = (setValueForKey_IMP)method_setImplementation(method, (IMP)replace_setValueForKey);
        
        method = class_getInstanceMethod(class, @selector(addEntriesFromDictionary:));
        origin_addEntriesFormDictionary = (addEntriesFormDictionary_IMP)method_setImplementation(method, (IMP)replace_addEntriesFormDictionary);
        
        method = class_getInstanceMethod(class, @selector(setDictionary:));
        origin_setDictionary = (setDictionary_IMP)method_setImplementation(method, (IMP)replace_setDitionary);
        
        method = class_getInstanceMethod(class, @selector(removeObjectForKey:));
        origin_removeObjectForKey = (removeObjectForKey_IMP)method_setImplementation(method, (IMP)replace_removeObjectForKey);
        
        method = class_getInstanceMethod(class, @selector(removeAllObjects));
        origin_removeAllObjects = (removeAllObjects_IMP)method_setImplementation(method, (IMP)replace_removeAllObjects);
        
        method = class_getInstanceMethod(class, @selector(removeObjectsForKeys:));
        origin_removeObjectsForKeys = (removeObjectsForKeys_IMP)method_setImplementation(method, (IMP)replace_removeObjectsForKeys);
        
    });
}

- (void)addObserver:(MutableDictionaryObserver *)observer {
    if (observer) {
        [self.observers addObject:observer];
        NSAssert(!isBlockStrongReference(observer.setObject, self), @"observer.setObject with self raise a block strong reference");
        NSAssert(!isBlockStrongReference(observer.setDictionary, self), @"observer.setDictionary with self raise a block strong reference");
        NSAssert(!isBlockStrongReference(observer.removeObjects, self), @"observer.removeObjects with self raise a block strong reference");
        
        NSAssert(!isBlockStrongReference(observer.setObject, observer), @"observer.setObject with observer raise a block strong reference");
        NSAssert(!isBlockStrongReference(observer.setDictionary, observer), @"observer.setDictionary with observer raise a block strong reference");
        NSAssert(!isBlockStrongReference(observer.removeObjects, observer), @"observer.removeObjects with observer raise a block strong reference");
    }
    
}
- (void)removeObserver:(MutableDictionaryObserver *)observer {
    if ([self.observers containsObject:observer]) {
        [self.observers removeObject:observer];
    }
}
- (BOOL)hasObserver {
    return self.observers.count > 0;
}
@end
