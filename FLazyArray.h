#import <Foundation/Foundation.h>

// Cannot return nil.
typedef id (^FLazyArrayResolver)(NSUInteger aIdx);

// Warning: In no way thread safe. (Nor are any derived collections)
@interface FLazyArray : NSObject
@property(nonatomic, readonly) NSUInteger count;
@property BOOL useProxies;

+ (instancetype)arrayWithCount:(NSUInteger)aCount resolver:(FLazyArrayResolver)aResolver;
- (id)objectAtIndex:(NSUInteger)aIdx;
- (id)objectAtIndexedSubscript:(NSUInteger)aIdx;
- (NSArray *)objectsInRange:(NSRange)aRange;
- (NSArray *)objectsAtIndexes:(NSIndexSet *)aIndexes;

// Require an object to be resolved again
- (void)forgetObjectAtIndex:(NSUInteger)aIdx;
- (void)forgetObjectsInRange:(NSRange)aRange;
- (void)forgetObjectsAtIndexes:(NSIndexSet *)aIndexes;
- (void)forgetAllObjects;

// Tell the array that the underlying datasource has inserted/deleted an item
- (void)insertObjectAtIndex:(NSUInteger)aIdx;
- (void)removeObjectAtIndex:(NSUInteger)aIdx;
- (void)removeObjectsAtAtIndexes:(NSIndexSet *)aIndexes;
@end

