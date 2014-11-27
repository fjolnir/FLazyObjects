#import "FLazyArray+DatabaseKit.h"
#import <DatabaseKit/DatabaseKit.h>

@implementation FLazyArray (DatabaseKit)
+ (instancetype)lazyArrayWithQuery:(DBSelectQuery * const)aQuery
{
    return !aQuery ? nil : [self lazyArrayWithCount:[aQuery count]
                                           resolver:^(NSIndexSet *aIndexes, __strong id *aoObjects)
    {
        __block __strong DBModel **objects = aoObjects;
        [aIndexes enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {
            DBSelectQuery *objectsInRange = [[aQuery offset:range.location] limit:range.length];
            for(DBModel *object in [objectsInRange execute]) {
                *objects++ = object;
            }
        }];
    }];
}
@end

