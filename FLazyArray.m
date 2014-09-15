#import "FLazyArray.h"
#import <objc/runtime.h>

@interface FLazyArray () {
    @protected
    FLazyArrayResolver _resolver;
    NSPointerArray *_array;
    NSMutableIndexSet *_resolvedIndexes;
}
@end

@implementation FLazyArray
@dynamic count;

+ (instancetype)lazyArrayWithCount:(NSUInteger const)aCount resolver:(FLazyArrayResolver const)aResolver
{
    FLazyArray * const array = [self new];
    array->_resolver    = aResolver;
    array->_array       = [NSPointerArray strongObjectsPointerArray];
    array->_array.count = aCount;
    return array;
}

- (instancetype)init
{
    if((self = [super init]))
        _resolvedIndexes = [NSMutableIndexSet new];
    return self;
}

- (void)_resolveIndexes:(NSIndexSet * const)aIndexes
{
    NSIndexSet *indexes = aIndexes;
    if([indexes count] < _batchSize) {
        indexes = [aIndexes mutableCopy];
        NSRange const validRange = { 0, [self count] };
        [aIndexes enumerateIndexesWithOptions:NSEnumerationReverse
                                   usingBlock:^(NSUInteger idx, BOOL *stop) {
            [(id)indexes addIndexesInRange:NSIntersectionRange(validRange,
                                                               (NSRange) { idx, _batchSize - [indexes count] })];
            if([indexes count] >= _batchSize)
                *stop = YES;
        }];
    }

    NSIndexSet * const unresolvedIndexes = [indexes indexesPassingTest:^BOOL(NSUInteger idx, BOOL *_) {
        return ![_resolvedIndexes containsIndex:idx];
    }];
    if([unresolvedIndexes count] == 0)
        return;

    __strong id * const newlyResolved = (__strong id *)calloc([unresolvedIndexes count], sizeof(id));
    _resolver(unresolvedIndexes, newlyResolved);

    __block __strong id *head = newlyResolved;
    [unresolvedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        NSAssert(*head, @"Object resolved to nil!");
        [_array replacePointerAtIndex:idx withPointer:(__bridge void *)*head++];
    }];
    [_resolvedIndexes addIndexes:unresolvedIndexes];
    free(newlyResolved);
}

- (id)objectAtIndex:(NSUInteger const)aIdx
{
    id object = (id)[_array pointerAtIndex:aIdx];
    if(__builtin_expect(object != nil, 1))
        return object;
    else {
        [self _resolveIndexes:[NSIndexSet indexSetWithIndex:aIdx]];
        return (id)[_array pointerAtIndex:aIdx];
    }
}
- (id)objectAtIndexedSubscript:(NSUInteger const)aIdx
{
    return [self objectAtIndex:aIdx];
}
- (NSArray *)objectsAtIndexes:(NSIndexSet * const)aIndexes
{
    if(![_resolvedIndexes containsIndexes:aIndexes])
        [self _resolveIndexes:aIndexes];

    NSMutableArray * const array = [NSMutableArray arrayWithCapacity:[aIndexes count]];
    [aIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [array addObject:self[idx]];
    }];
    return array;
}
- (NSArray *)objectsInRange:(NSRange const)aRange
{
    return [self objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:aRange]];
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
- (void)forgetObjectsAtIndexes:(NSIndexSet * const)aIndexes
{
    [_resolvedIndexes removeIndexes:aIndexes];
    [aIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [_array replacePointerAtIndex:idx withPointer:NULL];
    }];
}
- (void)forgetObjectsInRange:(NSRange const)aRange
{
    [self forgetObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:aRange]];
}

- (void)forgetAllObjects
{
    [_resolvedIndexes removeAllIndexes];
    NSUInteger const count = [self count];
    _array.count = 0;
    _array.count = count;
}

- (NSIndexSet *)resolvedIndexes
{
    return [_resolvedIndexes copy];
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

@implementation FMutableLazyArray

- (void)insertObjectAtIndex:(NSUInteger const)aIdx
{
    [_resolvedIndexes shiftIndexesStartingAtIndex:aIdx by:1];
    [_array insertPointer:NULL atIndex:aIdx];
}
- (void)removeObjectAtIndex:(NSUInteger)aIdx
{
    [_resolvedIndexes removeIndex:aIdx];
    [_resolvedIndexes shiftIndexesStartingAtIndex:aIdx+1 by:-1];
    [_array removePointerAtIndex:aIdx];
}
- (void)removeObjectsAtAtIndexes:(NSIndexSet *)aIndexes
{
    [_resolvedIndexes removeIndexes:aIndexes];
    [aIndexes enumerateIndexesWithOptions:NSEnumerationReverse
                               usingBlock:^(NSUInteger idx, BOOL *stop) {
        [_resolvedIndexes shiftIndexesStartingAtIndex:idx+1 by:-1];
        [_array removePointerAtIndex:idx];
    }];
}

@end
