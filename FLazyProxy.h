#import <Foundation/Foundation.h>

typedef id (^FLazyProxyResolver)();

@interface FLazyProxy : NSProxy
+ (instancetype)proxyWithBlock:(FLazyProxyResolver)aResolver;
@end

