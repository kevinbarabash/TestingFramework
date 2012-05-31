//
//  SpyTest.m
//  BlankARC
//
//  Created by Kevin Barabash on 12-04-14.
//  Copyright (c) 2012 Kevin Barabash. All rights reserved.
//

#import "SpyTest.h"
#import <UIKit/UIKit.h>
#import "Spy.h"
#import "Mock.h"

@implementation SpyTest

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testCallCount {
    NSString *string = @"hello, world!";
    Spy *spy = [Spy spyOn:&string];

    [string uppercaseString];
    [string uppercaseString];
    
    NSUInteger count = 2;
    STAssertEquals([spy callCountForSelector:@selector(uppercaseString)], count, @"call count was incorrect");
    
    string = spy.target;
}

- (void)testSpyCallsOriginalMethod {
    NSString *string = @"hello, world!";
    Spy *spy = [Spy spyOn:&string];
    
    NSString *expected = @"HELLO, WORLD!";
    NSString *actual = [string uppercaseString];
    
    STAssertEqualObjects(actual, expected, @"if a method has not been stubbed, the spy should call the original");
    
    string = spy.target;
}

- (void)testSpyGetCallArguments {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    Spy *spy = [Spy spyOn:&dict];
    
    [dict setObject:@"pineapple" forKey:@"fruit"];
    [dict setObject:@"boston cream" forKey:@"donut"];
    
    NSUInteger count = 2;
    STAssertEquals([spy callCountForSelector:@selector(setObject:forKey:)], count, @"asdf");
    
    id object, key;
    NSInvocation *firstInvocation = [spy invocationBySelector:@selector(setObject:forKey:) callNumber:0];
    NSInvocation *secondInvocation = [spy invocationBySelector:@selector(setObject:forKey:) callNumber:1];
    
    // index: 0 = self, 1 = _cmd
    [firstInvocation getArgument:&object atIndex:2];
    [firstInvocation getArgument:&key atIndex:3];
    STAssertEqualObjects(object, @"pineapple", @"the first arguments for the first call should be equal");
    STAssertEqualObjects(key, @"fruit", @"the first arguments for the first call should be equal");

    [secondInvocation getArgument:&object atIndex:2];
    [secondInvocation getArgument:&key atIndex:3];
    STAssertEqualObjects(object, @"boston cream", @"the second arguments for the first call should be equal");
    STAssertEqualObjects(key, @"donut", @"the second arguments for the first call should be equal");
    
    // returns the object to normal
    dict = spy.target;
}

- (void)testSpyGetLastCallArguments {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    Spy *spy = [Spy spyOn:&dict];
    
    [dict setObject:@"pineapple" forKey:@"fruit"];
    [dict setObject:@"boston cream" forKey:@"donut"];
    
    id object, key;
    NSInvocation *lastInvocation = [spy lastInvocationBySelector:@selector(setObject:forKey:)];
    
    [lastInvocation getArgument:&object atIndex:2];
    [lastInvocation getArgument:&key atIndex:3];
    STAssertEqualObjects(object, @"boston cream", @"the first arguments for the first call should be equal");
    STAssertEqualObjects(key, @"donut", @"the first arguments for the first call should be equal");
    
    // returns the object to normal
    dict = spy.target;
}

- (void)testSpyRestore {
    NSString *string = @"hello, world!";
    Spy *spy = [Spy spyOn:&string];
   
    [string uppercaseString];
    [spy reset];
    [string uppercaseString];
    
    NSUInteger count = 1;
    STAssertEquals([spy callCountForSelector:@selector(uppercaseString)], count, @"should only record method calls before restore");  
}

- (void)testSpyStubReturnObject
{
    NSString *str = @"hello, world!";
    Spy *spy = [Spy spyOn:&str];
    
    [spy stubSelector:@selector(uppercaseString) usingBlock:^(NSInvocation *invocation) {
        NSString *result = @"STUBBED RESULT";
        return [NSValue valueWithNonretainedObject:result];
    }];
    
    NSString *expected = @"STUBBED RESULT";
    NSString *actual = [str uppercaseString];
    
    STAssertEqualObjects(actual, expected, @"did not match");
}

- (void)testSpyStubBlockReturnPrimitives 
{
    NSNumber *number = [NSNumber numberWithInt:15];
    Spy *spy = [Spy spyOn:&number];
    
    int intResult = -454;
    [spy stubSelector:@selector(intValue) usingBlock:^(NSInvocation *invocation) {
        return [NSValue valueWithPointer:&intResult];
    }];
    STAssertEquals([number intValue], intResult, @"the ints should match");
    
    unsigned int uintResult = 343;
    [spy stubSelector:@selector(unsignedIntValue) usingBlock:^(NSInvocation *invocation) {
        return [NSValue valueWithPointer:&uintResult];
    }];
    STAssertEquals([number unsignedIntValue], uintResult, @"the unsigned ints should match");
    
    long longResult = -234998534;
    [spy stubSelector:@selector(longValue) usingBlock:^(NSInvocation *invocation) {
        return [NSValue valueWithPointer:&longResult];
    }];
    STAssertEquals([number longValue], longResult, @"the unsigned ints should match");
    
    unsigned long ulongResult = 129387453;
    [spy stubSelector:@selector(unsignedLongValue) usingBlock:^(NSInvocation *invocation) {
        return [NSValue valueWithPointer:&ulongResult];
    }];
    STAssertEquals([number unsignedLongValue], ulongResult, @"the unsigned ints should match");
    
    float floatResult = 1.23;
    [spy stubSelector:@selector(floatValue) usingBlock:^(NSInvocation *invocation) {
        return [NSValue valueWithPointer:&floatResult];
    }];
    STAssertEquals([number floatValue], floatResult, @"the unsigned ints should match");
    
    double doubleResult = 3.3258;
    [spy stubSelector:@selector(doubleValue) usingBlock:^(NSInvocation *invocation) {
        return [NSValue valueWithPointer:&doubleResult];
    }];
    STAssertEquals([number doubleValue], doubleResult, @"the unsigned ints should match");
}

- (void)testSpyStubReturnStruct
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
    Spy *spy = [Spy spyOn:&view];
    
    CGRect rect = CGRectMake(0, 0, 640, 480);
    [spy stubSelector:@selector(frame) usingBlock:^(NSInvocation *invocation) {
        return [NSValue valueWithPointer:&rect];
    }];
    
    CGRect expected = CGRectMake(0, 0, 640, 480);
    CGRect actual = [view frame];
    
    STAssertEquals(actual, expected, @"should return the correct struct");
}

- (void)testSpyStubAndReturnObject
{
    NSString *string = [NSString string];
    Spy *spy = [Spy spyOn:&string];
    
    [spy stubSelector:@selector(uppercaseString) andReturnObject:@"STUBBED RESULT"];
    
    NSString *expected = @"STUBBED RESULT";
    NSString *actual = [string uppercaseString];
    
    STAssertEqualObjects(actual, expected, @"the returned object didn't match");
}

- (void)testSpyStubAndReturnStructValues
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
    Spy *spy = [Spy spyOn:&view];
    
    CGRect rect = CGRectMake(0, 0, 320, 200);
    [spy stubSelector:@selector(frame) andReturnValue:&rect];
    
    CGRect expected = CGRectMake(0, 0, 320, 200);
    CGRect actual = [view frame];
    
    STAssertEquals(actual, expected, @"should return the correct struct");
}

- (void)testSpyStubAndReturnPrimitiveValues
{
    NSNumber *number = [NSNumber numberWithInt:15];
    Spy *spy = [Spy spyOn:&number];
    
    int intVal = -34;
    [spy stubSelector:@selector(intValue) andReturnValue:&intVal];
    STAssertEquals(intVal, [number intValue], @"the ints should match");
    
    unsigned int uintVal = 34;
    [spy stubSelector:@selector(unsignedIntValue) andReturnValue:&uintVal];
    STAssertEquals(uintVal, [number unsignedIntValue], @"the unsgined ints should match");
    
    long longVal = -12394354;
    [spy stubSelector:@selector(longValue) andReturnValue:&longVal];
    STAssertEquals(longVal, [number longValue], @"the longs should match");
    
    unsigned long ulongVal = 34198345;
    [spy stubSelector:@selector(unsignedLongValue) andReturnValue:&ulongVal];
    STAssertEquals(ulongVal, [number unsignedLongValue], @"the unsigned longs should match");
    
    float floatVal = 3.234;
    [spy stubSelector:@selector(floatValue) andReturnValue:&floatVal];
    STAssertEquals(floatVal, [number floatValue], @"the floats should match");
    
    double doubleVal = -1.23054;
    [spy stubSelector:@selector(doubleValue) andReturnValue:&doubleVal];
    STAssertEquals(doubleVal, [number doubleValue], @"the doubles should match");
}

- (void)testSpyOnMock
{
    id mock = [Mock mockClass:[NSString class]];
    Spy *spy = [Spy spyOn:&mock];
    
    [mock uppercaseString];
    [mock uppercaseString];
    
    NSUInteger count = 2;
    STAssertEquals(count, [spy callCountForSelector:@selector(uppercaseString)], @"call count is incorrect");
}

@end
