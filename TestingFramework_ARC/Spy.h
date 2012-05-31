//
//  Spy.h
//  Untitled Mock/Spy Framework
//
//  Created by Kevin Barabash on 12-03-27.
//  Copyright (c) 2012 Kevin Barabash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Stub.h"

@interface Spy : NSObject 

@property (readonly,nonatomic) id target;

+ (id)spyOn:(id *)target;

- (id)initWithTargetAddress:(id *)targetAddress;
- (void)reset;

- (NSArray *)invocationsBySelector:(SEL)sel;
- (NSInvocation *)invocationBySelector:(SEL)sel callNumber:(int)i;
- (NSInvocation *)lastInvocationBySelector:(SEL)sel;

- (void)stubSelector:(SEL)sel usingBlock:(StubBlock)block;
- (void)stubSelector:(SEL)sel andReturnValue:(void *)value;
- (void)stubSelector:(SEL)sel andReturnObject:(id)object;
- (void)restoreSelector:(SEL)sel;

- (NSUInteger)callCountForSelector:(SEL)sel;
@end
