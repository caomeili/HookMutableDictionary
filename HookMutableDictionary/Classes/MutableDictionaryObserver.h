//
//  MutableDictionaryObserver.h
//  Pods
//
//  Created by may on 2017/7/20.
//
//

#import <Foundation/Foundation.h>

typedef void(^didRemoveObjects)(NSMutableDictionary *dictionary ,NSArray<id> *keys);
typedef void(^didsetDictionary)(NSMutableDictionary *dictionary);
typedef void(^didSetObject)(NSMutableDictionary *dictionary,id object, id key);


@interface MutableDictionaryObserver : NSObject


/**
 removeObjects  删除键值对 对应回调的系统方法有
 - (void)removeObjectForKey:(KeyType)aKey;
 - (void)removeAllObjects;
 - (void)removeObjectsForKeys:(NSArray<KeyType> *)keyArray;
 */
@property (nonatomic, copy) didRemoveObjects removeObjects;

/**
 setDictionary  将整个字典赋值 对应回调的系统方法有
 - (void)setDictionary:(NSDictionary<KeyType, ObjectType> *)otherDictionary;
 - (void)addEntriesFromDictionary:(NSDictionary<KeyType, ObjectType> *)otherDictionary;
 */
@property (nonatomic, copy) didsetDictionary setDictionary;

/**
 setObject  添加键值对 对应回调的系统方法有
 - (void)setObject:(ObjectType)anObject forKey:(KeyType <NSCopying>)aKey;
 - (void)setObject:(nullable ObjectType)obj forKeyedSubscript:(KeyType <NSCopying>)key NS_AVAILABLE(10_8, 6_0);
 - (void)setValue:(nullable ObjectType)value forKey:(NSString *)key;
 */
@property (nonatomic, copy) didSetObject setObject;

@end
