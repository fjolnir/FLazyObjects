#import "FLazyProxy.h"

@interface FLazyProxy () {
    FLazyProxyResolver _resolver;
    id _object;
    BOOL _resolved;
}
@end

@implementation FLazyProxy

+ (instancetype)proxyWithBlock:(FLazyProxyResolver const)aResolver
{
    FLazyProxy * const proxy = [self alloc];
    NSParameterAssert(aResolver);
    proxy->_resolver = aResolver;
    return proxy;
}

- (id)_cy_object
{
    if(__builtin_expect(!_resolved, 0)) {
        _resolved = YES;
        _object = _resolver();
    }
    return _object;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    [anInvocation setTarget:[self _cy_object]];
    [anInvocation invoke];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    return [[self _cy_object] methodSignatureForSelector:aSelector];
}

@end

