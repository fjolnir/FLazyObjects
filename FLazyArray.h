#import <Foundation/Foundation.h>

// Cannot return nil.
typedef void (^FLazyArrayResolver)(NSIndexSet *aIndexes, __strong id *aoObjects);

// Warning: In no way thread safe. (Nor are any derived collections)
@interface FLazyArray : NSArray
@property(nonatomic, readonly, copy) NSIndexSet *resolvedIndexes;
@property(nonatomic, readonly) NSUInteger count;
@property(nonatomic) NSUInteger batchSize;

+ (instancetype)lazyArrayWithCount:(NSUInteger)aCount resolver:(FLazyArrayResolver)aResolver;
- (id)objectAtIndex:(NSUInteger)aIdx;
- (id)objectAtIndexedSubscript:(NSUInteger)aIdx;
- (NSArray *)objectsAtIndexes:(NSIndexSet *)aIndexes;
- (NSArray *)objectsInRange:(NSRange)aRange;

// Require an object to be resolved again
- (void)forgetObjectAtIndex:(NSUInteger)aIdx;
- (void)forgetObjectsAtIndexes:(NSIndexSet *)aIndexes;
- (void)forgetObjectsInRange:(NSRange)aRange;
- (void)forgetAllObjects;
@end

@interface FMutableLazyArray : FLazyArray
// Tell the array that the underlying datasource has inserted/deleted an item
- (void)insertObjectAtIndex:(NSUInteger)aIdx;
- (void)removeObjectAtIndex:(NSUInteger)aIdx;
- (void)removeObjectsAtAtIndexes:(NSIndexSet *)aIndexes;
@end


#define FLazyArrayUnavailable __attribute__((unavailable))
@interface FLazyArray (UnavailableMethods)
+ (instancetype)array FLazyArrayUnavailable;
+ (instancetype)arrayWithObject:(id)anObject FLazyArrayUnavailable;
+ (instancetype)arrayWithObjects:(const id [])objects count:(NSUInteger)cnt FLazyArrayUnavailable;
+ (instancetype)arrayWithObjects:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION FLazyArrayUnavailable;
+ (instancetype)arrayWithArray:(NSArray *)array FLazyArrayUnavailable;

- (instancetype)initWithObjects:(const id [])objects count:(NSUInteger)cnt FLazyArrayUnavailable;

- (instancetype)initWithObjects:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION FLazyArrayUnavailable;
- (instancetype)initWithArray:(NSArray *)array FLazyArrayUnavailable;
- (instancetype)initWithArray:(NSArray *)array copyItems:(BOOL)flag FLazyArrayUnavailable;

+ (id)arrayWithContentsOfFile:(NSString *)path FLazyArrayUnavailable;
+ (id)arrayWithContentsOfURL:(NSURL *)url FLazyArrayUnavailable;
- (id)initWithContentsOfFile:(NSString *)path FLazyArrayUnavailable;
- (id)initWithContentsOfURL:(NSURL *)url FLazyArrayUnavailable;
@end