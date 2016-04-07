//
//  DataWrapper.h
//  NSDictionary或NSArray封装类，安全读取
//  HoneyAnt
//
//  Created by Will Zhang on 15-1-4.
//  Copyright (c) 2015年 LEVP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface DataWrapper : NSObject <NSCopying>

// attach object
+ (DataWrapper*)dataWrapperWithObject:(id)object;

// 获取关联的NSDictionary或NSArray子元素数量
- (NSUInteger)count;

// 获取关联的NSDictionary或NSArray
- (id)getObject;

// 将关联的NSDictionary或NSArray转为字符串输出
- (NSString*)toString;

// 打印关联的NSDictionary或NSArray
- (void)printObject;

// 对NSDictionary操作
- (id)objectForKey:(NSString*)key; // 获取关联的NSDictionary的子对象
//如果key对应的value为array 返回array， 否则返回nil
- (id)arrayForKey:(NSString*)key;
- (DataWrapper*)dataWrapperForKey:(NSString*)key;
- (NSString*)stringForKey:(NSString*)key;
- (int)intForKey:(NSString*)key;
- (long long)longLongForKey:(NSString*)key;
- (float)floatForKey:(NSString*)key;
- (double)doubleForKey:(NSString*)key;
- (BOOL)boolForKey:(NSString*)key;

// 对NSArray操作
- (id)objectForIndex:(int)index; // 获取关联的NSArray的子对象
- (DataWrapper*)dataWrapperForIndex:(int)index;
- (NSString*)stringForIndex:(int)index;
- (int)intForIndex:(int)index;
- (long long)longLongForIndex:(int)index;
- (float)floatForIndex:(int)index;
- (double)doubleForIndex:(int)index;
- (BOOL)boolForIndex:(int)index;

@end
