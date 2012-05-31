//
//  Mock.m
//  Mocking_without_ARC
//
//  Created by Kevin Barabash on 12-03-21.
//  Copyright (c) 2012 Kevin Barabash. All rights reserved.
//

#import "Mock.h"
#import <objc/objc-class.h>

@interface Mock () {
    NSMutableDictionary *stubs;
    Class cls;
}
@end

@implementation Mock

+ (id)mockClass:(Class)aClass {
    return [[Mock alloc] initWithClass:aClass];
}

- (id)initWithClass:(Class)aClass {
    if (self = [super init]) {
        cls = aClass;
        stubs = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)forwardInvocation:(NSInvocation*) invocation
{
	SEL sel = [invocation selector];
    
    NSString *selString = NSStringFromSelector(sel);
        
    StubBlock block = [stubs objectForKey:selString];
    if (block) {
        
        NSString *returnType = [NSString stringWithCString:invocation.methodSignature.methodReturnType 
                                                  encoding:NSUTF8StringEncoding];
        NSValue *returnValue = block(invocation);
        
        if (returnValue) {
            if ([returnType isEqualToString:@"@"]) {
                id object = returnValue.nonretainedObjectValue;
                [invocation setReturnValue:&object];
            } else {
                [invocation setReturnValue:returnValue.pointerValue];
            }
        }
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [cls instancesRespondToSelector:aSelector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *sig = [cls instanceMethodSignatureForSelector:aSelector];
    return sig;
}

- (void)stubSelector:(SEL)sel usingBlock:(StubBlock)block {
    [stubs setObject:block forKey:NSStringFromSelector(sel)];
}

- (void)stubSelector:(SEL)sel andReturnValue:(void *)value {
    [self stubSelector:sel usingBlock:^(NSInvocation *invocation) {
        return [NSValue valueWithPointer:value];
    }];
}

- (void)stubSelector:(SEL)sel andReturnObject:(id)object {
    [self stubSelector:sel usingBlock:^(NSInvocation *invocation) {
        return [NSValue valueWithNonretainedObject:object];
    }];
}
@end
