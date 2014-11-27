#import "FLazyArray.h"

@class DBSelectQuery;

@interface FLazyArray (DatabaseKit)
+ (instancetype)lazyArrayWithQuery:(DBSelectQuery *)aQuery;
@end

