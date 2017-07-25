//
//  NSMutableDictionary+HookC.h
//  Pods
//
//  Created by may on 2017/7/20.
//
//

#import <Foundation/Foundation.h>
#import "MutableDictionaryObserver.h"

@interface NSMutableDictionary (HookC)
-(BOOL)hasObserver;
/**
 添加监听者
 
 @param observer 监听者
 */
-(void)addObserver:(MutableDictionaryObserver *)observer;

/**
 移除监听者
 
 @param observer 监听者
 */
-(void)removeObserver:(MutableDictionaryObserver *)observer;
@end
