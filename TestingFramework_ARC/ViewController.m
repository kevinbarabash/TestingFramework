//
//  ViewController.m
//  TestingFramework_ARC
//
//  Created by Kevin Barabash on 12-05-01.
//  Copyright (c) 2012 Kevin Barabash. All rights reserved.
//

#import "ViewController.h"
#import "Mock.h"
#import "Spy.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    NSLog(@"SPY");
    NSLog(@" ");
    
    NSString *str = @"hello, world!";
    id spy = [Spy spyOn:&str];
    
    NSLog(@"uppercase = %@", [spy uppercaseString]);
    
    if ([spy isEqualToString:@"hello, world!"]) {
        NSLog(@"EQUAL to '%@'", @"hello, world!");
    } else {
        NSLog(@"NOT EQUAL '%@'", @"hello, world!");
    }
    
    if ([spy isEqualToString:@"blah"]) {
        NSLog(@"EQUAL to '%@'", @"blah");
    } else {
        NSLog(@"NOT EQUAL to '%@'", @"blah");
    }
    
    [spy characterAtIndex:7];
    
    NSLog(@" ");
    NSLog(@"GET CALL COUNTS");
    NSLog(@"uppercase call count = %d", [spy callCountForSelector:@selector(uppercaseString)]);
    NSLog(@"isEqualToString: call count = %d", [spy callCountForSelector:@selector(isEqualToString:)]);
    
    NSLog(@" ");
    NSLog(@"GET ARGUMENTS");
    
    NSInvocation *invocation;
    id arg;
    
    invocation = [spy invocationBySelector:@selector(isEqualToString:) callNumber:0];
    [invocation getArgument:&arg atIndex:2];
    NSLog(@"args for isEqualToString: (first call) = %@", arg);
    
    invocation = [spy invocationBySelector:@selector(isEqualToString:) callNumber:1];
    [invocation getArgument:&arg atIndex:2];
    NSLog(@"args for isEqualToString: (second call) = %@", arg);
    
    invocation = [spy invocationBySelector:@selector(characterAtIndex:) callNumber:0];
    int iArg;
    [invocation getArgument:&iArg atIndex:2];
    NSLog(@"args for characterAtIndex: (first call) = %d", iArg);
    
    
    NSLog(@" ");
    NSLog(@"STUBBING SPIES");
    
    NSString *stubbedResult = @"STUBBED RESULT";
    [spy stubSelector:@selector(uppercaseString) usingBlock:^(NSInvocation *invocation) {
        NSLog(@"  inside a stubbed selector");
        NSLog(@"  [target class] = %@", [[invocation.target class] description]);
        NSLog(@"  sel = %@", NSStringFromSelector(invocation.selector));
        Spy *target = invocation.target;
        NSLog(@"  spy's target class = %@", [[target.target class] description]);
        NSLog(@"  actual length = %d", [target.target length]);
        NSLog(@"  actual uppercaseString = %@", [target.target uppercaseString]);
        
        return [NSValue valueWithNonretainedObject:stubbedResult];
    }];
    NSLog(@"uppercase = %@", [spy uppercaseString]);
    NSLog(@"uppercase call count = %d", [spy callCountForSelector:@selector(uppercaseString)]);
    
    
    NSLog(@" ");
    NSLog(@" ");
    NSLog(@"MOCK");
    NSLog(@" ");
    
    id mock = [Mock mockClass:[NSString class]];
    
    [mock stubSelector:@selector(uppercaseString) usingBlock:^(NSInvocation *invocation) {
        NSString *result = @"This is a stubbed result";
        return [NSValue valueWithNonretainedObject:result];
    }];
    
    unsigned int result = 25;
    [mock stubSelector:@selector(length) usingBlock:^(NSInvocation *invocation) {
        return [NSValue valueWithPointer:&result];
    }];
    
    
    
    NSLog(@"[mock uppercaseString] = %@", [mock uppercaseString]);
    NSLog(@"[mock length] = %d", [mock length]);
    
    NSLog(@" ");
    NSLog(@"ACCESSING ARGS INSIDE A STUB");
    
    [mock stubSelector:@selector(characterAtIndex:) usingBlock:^(NSInvocation *invocation) {
        NSLog(@"  inside a stubbed selector");
        NSLog(@"  self = %@", invocation.self);
        NSLog(@"  [self class] = %@", [[invocation.self class] description]);
        NSLog(@"  [target class] = %@", [[invocation.target class] description]);    
        NSLog(@"  sel = %@", NSStringFromSelector(invocation.selector));
        int intArg;
        [invocation getArgument:&intArg atIndex:2];
        NSLog(@"  first real argument = %d", intArg);    
        
        unsigned short result = 54;
        return [NSValue valueWithPointer:&result];
    }];
    
    [mock characterAtIndex:843];
    
    NSLog(@" ");
    NSLog(@" ");
    NSLog(@"SPY ON MOCK");
    
    id mockSpy = [Spy spyOn:&mock];
    
    NSLog(@"[mockSpy uppercaseString] = %@", [mockSpy uppercaseString]);
    NSLog(@"[mockSpy length] = %d", [mockSpy length]);
    
    NSLog(@" ");
    NSLog(@"CALL COUNTS");
    NSLog(@"[mockSpy uppercaseString] call count = %d", [mockSpy callCountForSelector:@selector(uppercaseString)]);
    NSLog(@"[mockSpy length] call count = %d", [mockSpy callCountForSelector:@selector(length)]);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
