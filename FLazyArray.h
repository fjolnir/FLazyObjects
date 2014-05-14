#import <Foundation/Foundation.h>

// Cannot return nil.
typedef id (^FLazyArrayResolver)(NSUInteger aIdx);

// Warning: In no way thread safe.
@interface FLazyArray : NSObject
@property(readonly) NSUInteger count;

+ (instancetype)arrayWithCount:(NSUInteger)aCount resolver:(FLazyArrayResolver)aResolver;
- (id)objectAtIndex:(NSUInteger)aIdx;
- (id)objectAtIndexedSubscript:(NSUInteger)aIdx;

// Require an object to be resolved againb
- (void)forgetObjectAtIndex:(NSUInteger)aIdx;
// Tell the array that the underlying datasource has inserted/deleted an item
- (void)insertObjectAtIndex:(NSUInteger)aIdx;
- (void)removeObjectAtIndex:(NSUInteger)aIdx;
@end

