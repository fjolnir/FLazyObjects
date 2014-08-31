#import <Foundation/Foundation.h>

// Cannot return nil.
typedef void (^FLazyArrayResolver)(NSIndexSet *aIndexes, __strong id *aoObjects);

// Warning: In no way thread safe. (Nor are any derived collections)
@interface FLazyArray : NSObject
@property(nonatomic, readonly) NSUInteger count;

+ (instancetype)arrayWithCount:(NSUInteger)aCount resolver:(FLazyArrayResolver)aResolver;
- (id)objectAtIndex:(NSUInteger)aIdx;
- (id)objectAtIndexedSubscript:(NSUInteger)aIdx;
- (NSArray *)objectsAtIndexes:(NSIndexSet *)aIndexes;
- (NSArray *)objectsInRange:(NSRange)aRange;

// Require an object to be resolved again
- (void)forgetObjectAtIndex:(NSUInteger)aIdx;
- (void)forgetObjectsAtIndexes:(NSIndexSet *)aIndexes;
- (void)forgetObjectsInRange:(NSRange)aRange;
- (void)forgetAllObjects;

// Tell the array that the underlying datasource has inserted/deleted an item
- (void)insertObjectAtIndex:(NSUInteger)aIdx;
- (void)removeObjectAtIndex:(NSUInteger)aIdx;
- (void)removeObjectsAtAtIndexes:(NSIndexSet *)aIndexes;
@end

