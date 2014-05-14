#import "FLazyArray.h"
#import "FLazyProxy.h"
#import <objc/runtime.h>

@interface FLazyArray () {
    FLazyArrayResolver _resolver;
    NSPointerArray *_array;
    NSMutableIndexSet *_resolvedIndexes;
}
@end

@implementation FLazyArray
@dynamic count;

+ (FLazyArray *)arrayWithCount:(NSUInteger const)aCount resolver:(FLazyArrayResolver const)aResolver
{
    FLazyArray * const array = [self new];
    array->_resolver    = aResolver;
    array->_array       = [NSPointerArray strongObjectsPointerArray];
    array->_array.count = aCount;
    return array;
}

- (id)init
{
    if((self = [super init]))
        _resolvedIndexes = [NSMutableIndexSet new];
    return self;
}

- (void)_resolveIndex:(NSUInteger const)aIdx
{
    if([_resolvedIndexes containsIndex:aIdx])
        return;

    id const object = _resolver(aIdx);
    NSAssert(object, @"Tried to insert nil into array!");
    [_array replacePointerAtIndex:aIdx withPointer:(__bridge void*)object];
    [_resolvedIndexes addIndex:aIdx];
}

- (id)objectAtIndex:(NSUInteger const)aIdx
{
    id object = (id)[_array pointerAtIndex:aIdx];
    if(!object) {
        object = [FLazyProxy proxyWithBlock:^{
            [self _resolveIndex:aIdx];
            return (id)[_array pointerAtIndex:aIdx];
        }];
        [_array replacePointerAtIndex:aIdx withPointer:(__bridge void*)object];
    }
    return object;
}
- (id)objectAtIndexedSubscript:(NSUInteger const)aIdx
{
    return [self objectAtIndex:aIdx];
}

- (NSUInteger)count
{
    return [_array count];
}

- (void)forgetObjectAtIndex:(NSUInteger)aIdx
{
    [_resolvedIndexes removeIndex:aIdx];
    [_array replacePointerAtIndex:aIdx withPointer:NULL];
}

- (void)insertObjectAtIndex:(NSUInteger const)aIdx
{
    [_resolvedIndexes shiftIndexesStartingAtIndex:aIdx by:1];
    [_array insertPointer:NULL atIndex:aIdx];
}
- (void)removeObjectAtIndex:(NSUInteger)aIdx
{
    [_resolvedIndexes shiftIndexesStartingAtIndex:aIdx by:-1];
    [_array removePointerAtIndex:aIdx];
}


- (NSString *)description
{
    NSMutableString * const desc = [NSMutableString stringWithFormat:@"<%@: %p\n", [self class], self];
    for(NSUInteger i = 0; i < [_array count]; ++i) {
        [desc appendFormat:@"    %@,\n", [_resolvedIndexes containsIndex:i] 
                                         ? (id)[_array pointerAtIndex:i] 
                                         : @"(unresolved)"];
    }
    [desc appendString:@">"];
    return desc;
}

@end

