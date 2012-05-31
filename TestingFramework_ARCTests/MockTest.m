//
//  MockTest.m
//  MockTest
//
//  Created by Kevin Barabash on 12-04-14.
//  Copyright (c) 2012 Kevin Barabash. All rights reserved.
//

#import "MockTest.h"
#import <UIKit/UIKit.h>
#import "Mock.h"

@implementation MockTest

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{    
    [super tearDown];
}

- (void)testMockStubReturnObject
{
    id mock = [Mock mockClass:[NSString class]];
    
    [mock stubSelector:@selector(uppercaseString) usingBlock:^(NSInvocation *invocation) {
        NSString *result = @"STUBBED RESULT";
        return [NSValue valueWithNonretainedObject:result];
    }];
    
    NSString *expected = @"STUBBED RESULT";
    NSString *actual = [mock uppercaseString];
    
    STAssertEqualObjects(actual, expected, @"did not match");
}

- (void)testMockStubBlockReturnPrimitives 
{
    id mock = [Mock mockClass:[NSNumber class]];
    
    int intResult = -454;
    [mock stubSelector:@selector(intValue) usingBlock:^(NSInvocation *invocation) {
        return [NSValue valueWithPointer:&intResult];
    }];
    STAssertEquals([mock intValue], intResult, @"the ints should match");
    
    unsigned int uintResult = 343;
    [mock stubSelector:@selector(unsignedIntValue) usingBlock:^(NSInvocation *invocation) {
        return [NSValue valueWithPointer:&uintResult];
    }];
    STAssertEquals([mock unsignedIntValue], uintResult, @"the unsigned ints should match");
    
    long longResult = -234998534;
    [mock stubSelector:@selector(longValue) usingBlock:^(NSInvocation *invocation) {
        return [NSValue valueWithPointer:&longResult];
    }];
    STAssertEquals([mock longValue], longResult, @"the unsigned ints should match");
    
    unsigned long ulongResult = 129387453;
    [mock stubSelector:@selector(unsignedLongValue) usingBlock:^(NSInvocation *invocation) {
        return [NSValue valueWithPointer:&ulongResult];
    }];
    STAssertEquals([mock unsignedLongValue], ulongResult, @"the unsigned ints should match");

    float floatResult = 1.23;
    [mock stubSelector:@selector(floatValue) usingBlock:^(NSInvocation *invocation) {
        return [NSValue valueWithPointer:&floatResult];
    }];
    STAssertEquals([mock floatValue], floatResult, @"the unsigned ints should match");
    
    double doubleResult = 3.3258;
    [mock stubSelector:@selector(doubleValue) usingBlock:^(NSInvocation *invocation) {
        return [NSValue valueWithPointer:&doubleResult];
    }];
    STAssertEquals([mock doubleValue], doubleResult, @"the unsigned ints should match");
}

- (void)testMockStubReturnTypeMismatch
{
    id mock = [Mock mockClass:[NSNumber class]];
    
    [mock stubSelector:@selector(doubleValue) usingBlock:^(NSInvocation *invocation) {
        NSString *result = @"Hello, world!";
        return [NSValue valueWithNonretainedObject:result];
    }];
    
    STAssertNoThrow([mock doubleValue], @"should not throw an exception on block return type mismatch with mocked method's return type");
}

- (void)testMockStubThrowsExpection
{
    id mock = [Mock mockClass:[NSNumber class]];
    
    [mock stubSelector:@selector(uppercaseString) usingBlock:^(NSInvocation *invocation) {
        NSString *result = @"HELLO, WORLD!";
        return [NSValue valueWithNonretainedObject:result];
    }];
      
    STAssertThrows([mock uppercaseString], @"should throw an exception when calling methods that do not exist in the mocked class");
}

- (void)testMockStubReturnStruct
{
    id mock = [Mock mockClass:[UIView class]];
    
    CGRect rect = CGRectMake(0, 0, 320, 200);
    [mock stubSelector:@selector(frame) usingBlock:^(NSInvocation *invocation) {
        return [NSValue valueWithPointer:&rect];
    }];
    
    CGRect expected = CGRectMake(0, 0, 320, 200);
    CGRect actual = [mock frame];
    
    STAssertEquals(actual, expected, @"should return the correct struct");
}

- (void)testMockStubAndReturnObject
{
    id mock = [Mock mockClass:[NSString class]];
    
    [mock stubSelector:@selector(uppercaseString) andReturnObject:@"STUBBED RESULT"];
    
    NSString *expected = @"STUBBED RESULT";
    NSString *actual = [mock uppercaseString];
    
    STAssertEqualObjects(actual, expected, @"the returned object didn't match");
}

- (void)testMockStubAndReturnStructValues
{
    id mock = [Mock mockClass:[UIView class]];
    
    CGRect rect = CGRectMake(0, 0, 320, 200);
    [mock stubSelector:@selector(frame) andReturnValue:&rect];
    
    CGRect expected = CGRectMake(0, 0, 320, 200);
    CGRect actual = [mock frame];
    
    STAssertEquals(actual, expected, @"should return the correct struct");
}

- (void)testMockStubAndReturnPrimitiveValues
{
    id mock = [Mock mockClass:[NSNumber class]];
    
    int intVal = -34;
    [mock stubSelector:@selector(intValue) andReturnValue:&intVal];
    STAssertEquals(intVal, [mock intValue], @"the ints should match");
    
    unsigned int uintVal = 34;
    [mock stubSelector:@selector(unsignedIntValue) andReturnValue:&uintVal];
    STAssertEquals(uintVal, [mock unsignedIntValue], @"the unsgined ints should match");

    long longVal = -12394354;
    [mock stubSelector:@selector(longValue) andReturnValue:&longVal];
    STAssertEquals(longVal, [mock longValue], @"the longs should match");
    
    unsigned long ulongVal = 34198345;
    [mock stubSelector:@selector(unsignedLongValue) andReturnValue:&ulongVal];
    STAssertEquals(ulongVal, [mock unsignedLongValue], @"the unsigned longs should match");
    
    float floatVal = 3.234;
    [mock stubSelector:@selector(floatValue) andReturnValue:&floatVal];
    STAssertEquals(floatVal, [mock floatValue], @"the floats should match");
    
    double doubleVal = -1.23054;
    [mock stubSelector:@selector(doubleValue) andReturnValue:&doubleVal];
    STAssertEquals(doubleVal, [mock doubleValue], @"the doubles should match");
}

- (void)testMockStubArgumentAccess 
{
    id mock = [Mock mockClass:[NSMutableDictionary class]];

    [mock stubSelector:@selector(setObject:forKey:) usingBlock:^NSValue *(NSInvocation *invocation) {
        // arg0 = self, arg0 = _cmd
        
        id object, key;
        
        [invocation getArgument:&object atIndex:2];
        [invocation getArgument:&key atIndex:3];
                
        STAssertEqualObjects(key, @"fruit", @"the keys should be equal");
        STAssertEqualObjects(object, @"pineapple", @"the objects should be equal");
        
        return nil;
    }];
    
    [mock setObject:@"pineapple" forKey:@"fruit"];
}

- (void)testMockStubReturnNil
{
    id mock = [Mock mockClass:[NSMutableArray class]];
    
    [mock stubSelector:@selector(addObject:) usingBlock:^NSValue *(NSInvocation *invocation) {
        return nil;
    }];
    
    STAssertNoThrow([mock addObject:@"object"], @"should not throw an exception with a block that returns nil");
}
@end
