//
//  DataWrapper.m
//  HoneyAnt
//
//  Created by Will Zhang on 15-1-4.
//  Copyright (c) 2015年 LEVP. All rights reserved.
//

#import "DataWrapper.h"
#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif

@interface DataWrapper()

@property(nonatomic, strong)id object;

@end



@implementation DataWrapper

- (id)copyWithZone:(NSZone*)zone
{
    DataWrapper *result = [[[self class] allocWithZone:zone] init];
    result.object = self.object;
    return result;
}

- (BOOL)isEqual:(id)anObject
{
    if ([anObject isKindOfClass:[DataWrapper class]]) {
        return self.object == [anObject object];
    }
    
    return NO;
}

- (NSUInteger)hash
{
    return [self.object hash];
}

- (NSString*)description
{
    return [self.object description];
}

+ (DataWrapper*)dataWrapperWithObject:(id)object
{
    DataWrapper *jsonObj = [[DataWrapper alloc] init];
    if ([object isKindOfClass:[NSDictionary class]] || [object isKindOfClass:[NSArray class]]) {
        jsonObj.object = object;
    }
    
    return jsonObj;
}

- (NSUInteger)count
{
    NSUInteger ret = 0;
    
    if ([self.object respondsToSelector:@selector(count)]) {
        ret = [self.object count];
    }
    
    return ret;
}

- (id)getObject
{
    return self.object;
}

- (NSString*)toString
{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.object options:0 error:&error];
    
    NSString *stringData = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return stringData;
}

- (void)printObject
{
    NSLog(@"object is:\r\n %@", self.object);
}

#pragma mark - Get json element functions
- (id)objectForKey:(NSString*)key
{
    id retObj = nil;
    
    if ([self.object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary*)self.object;
        retObj = [dict objectForKey:key];
    }
    
    return retObj;
}


//如果key对应的value为array 返回array， 否则返回nil
- (id)arrayForKey:(NSString*)key{

    id retObj = nil;
    
    if ([self.object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary*)self.object;
        retObj = [dict objectForKey:key];
    }
    
    if ([retObj isKindOfClass:[NSArray class]]) {
        return retObj;
    }
    return [NSArray array];
}

- (DataWrapper*)dataWrapperForKey:(NSString*)key
{
    id retObj = nil;
    
    if ([self.object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary*)self.object;
        retObj = [dict objectForKey:key];
    }
    
    if (retObj == nil) {
        retObj = [NSDictionary dictionary];
    }
    
    return [DataWrapper dataWrapperWithObject:retObj];
}

- (NSString*)stringForKey:(NSString*)key
{
    id retObj = [NSString string];
    
    if ([self.object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary*)self.object;
        retObj = [dict objectForKey:key];
        
        if ([retObj isKindOfClass:[NSNumber class]]) {
            retObj = [retObj stringValue];
        }
        
        if (![retObj isKindOfClass:[NSString class]]) {
            retObj = [NSString string];
        }
    }
    
    return retObj;
}

- (int)intForKey:(NSString*)key
{
    return [[self stringForKey:key] intValue];
}

- (long long)longLongForKey:(NSString*)key
{
    return [[self stringForKey:key] longLongValue];
}

- (float)floatForKey:(NSString*)key
{
    return [[self stringForKey:key] floatValue];
}

- (double)doubleForKey:(NSString*)key
{
    return [[self stringForKey:key] doubleValue];
}

- (BOOL)boolForKey:(NSString*)key
{
    return [[self stringForKey:key] boolValue];
}

#pragma mark - for array

- (id)objectForIndex:(int)index
{
    id retObj = nil;
    if ([self.object isKindOfClass:[NSArray class]]) {
        NSArray *array = (NSArray*)self.object;
        if ([array count] > index) {
            retObj = [array objectAtIndex:index];
        }
    }
    
    return retObj;
}

- (DataWrapper*)dataWrapperForIndex:(int)index
{
    id retObj = nil;
    if ([self.object isKindOfClass:[NSArray class]]) {
        NSArray *array = (NSArray*)self.object;
        if ([array count] > index) {
            retObj = [array objectAtIndex:index];
        }
    }
    
    if (retObj == nil) {
        retObj = [NSArray array];
    }
    
    return [DataWrapper dataWrapperWithObject:retObj];
}

- (NSString*)stringForIndex:(int)index
{
    id retObj = [NSString string];
    if ([self.object isKindOfClass:[NSArray class]]) {
        NSArray *array = (NSArray*)self.object;
        if ([array count] > index) {
            retObj = [array objectAtIndex:index];
        }
        
        if ([retObj isKindOfClass:[NSNumber class]]) {
            retObj = [retObj stringValue];
        }
        
        if (![retObj isKindOfClass:[NSString class]]) {
            retObj = [NSString string];
        }
    }
    
    return retObj;
}

- (int)intForIndex:(int)index
{
    return [[self stringForIndex:index] intValue];
}

- (long long)longLongForIndex:(int)index
{
    return [[self stringForIndex:index] longLongValue];
}

- (float)floatForIndex:(int)index
{
    return [[self stringForIndex:index] floatValue];
}

- (double)doubleForIndex:(int)index
{
    return [[self stringForIndex:index] doubleValue];
}

- (BOOL)boolForIndex:(int)index
{
    return [[self stringForIndex:index] boolValue];
}

@end
