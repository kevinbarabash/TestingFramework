//
//  Mock.h
//  Untitled Mock/Spy Framework
//
//  Created by Kevin Barabash on 12-03-21.
//  Copyright (c) 2012 Kevin Barabash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Stub.h"

@interface Mock : NSObject

+ (id)mockClass:(Class)aClass;
- (void)stubSelector:(SEL)sel usingBlock:(StubBlock)block;
- (void)stubSelector:(SEL)sel andReturnValue:(void *)value;
- (void)stubSelector:(SEL)sel andReturnObject:(id)object;
@end
