//
//  Spy.m
//  Mocking_without_ARC
//
//  Created by Kevin Barabash on 12-03-27.
//  Copyright (c) 2012 Kevin Barabash. All rights reserved.
//

#import "Spy.h"
#import <objc/objc-class.h>

@interface Spy () {
    NSMutableDictionary *invocations;
    NSMutableDictionary *stubs;
    __autoreleasing id *_targetAddress;
}
@end

@implementation Spy
@synthesize target = _target;

+ (id)spyOn:(id *)target {
    return [[Spy alloc] initWithTargetAddress:target];
}

- (id)initWithTargetAddress:(id *)targetAddress {
    if (self = [super init]) {
        _targetAddress = targetAddress;
        _target = *targetAddress;
        
        // replaces the target with 
        *targetAddress = self;
        
        invocations = [NSMutableDictionary dictionary];
        stubs = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)forwardInvocation:(NSInvocation*) invocation
{
	SEL sel = [invocation selector];

    if (![self.target respondsToSelector:sel]) {
        [self doesNotRecognizeSelector:sel];
        return;
    }

    NSString *selString = NSStringFromSelector(sel);
    if (![invocations objectForKey:selString]) {
        [invocations setObject:[NSMutableArray array] forKey:selString];
    }
    
    [[invocations objectForKey:selString] addObject:invocation];
    
    StubBlock block = [stubs objectForKey:selString];
    if (block) {
        NSString *returnType = [NSString stringWithCString:invocation.methodSignature.methodReturnType 
                                                  encoding:NSUTF8StringEncoding];
        NSValue *returnValue = block(invocation);
        
        if ([returnType isEqualToString:@"@"]) {
            id object = returnValue.nonretainedObjectValue;
            [invocation setReturnValue:&object];
        } else {
            [invocation setReturnValue:returnValue.pointerValue];
        }
    } else {
        [invocation invokeWithTarget:self.target];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *sig = [self.target methodSignatureForSelector:aSelector];
    return sig;
}

- (NSArray *)invocationsBySelector:(SEL)sel {
    return [NSArray arrayWithArray:[invocations objectForKey:NSStringFromSelector(sel)]];
}

- (NSInvocation *)invocationBySelector:(SEL)sel callNumber:(int)i {
    NSArray *selInvokes = [invocations objectForKey:NSStringFromSelector(sel)];
    if (i < [selInvokes count]) {
        return [selInvokes objectAtIndex:i];
    }    
    return nil;
}

- (NSInvocation *)lastInvocationBySelector:(SEL)sel {
    return [[invocations objectForKey:NSStringFromSelector(sel)] lastObject];
}

- (NSUInteger)callCountForSelector:(SEL)sel {
    return [[invocations objectForKey:NSStringFromSelector(sel)] count];
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

- (void)restoreSelector:(SEL)sel {
    [stubs removeObjectForKey:NSStringFromSelector(sel)];
}

- (void)reset {    
    *_targetAddress = self.target;
    invocations = [NSMutableDictionary dictionary];
}
@end
