#import <Foundation/Foundation.h>

typedef id (^FLazyProxyResolver)(void);

@interface FLazyProxy : NSProxy
+ (instancetype)proxyWithBlock:(FLazyProxyResolver)aResolver;
@end

