//
//  SRTAutobahnTests.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/20.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <XCTest/XCTestRun.h>
#import "SRWebSocket.h"
#import "SRTWebSocketOperation.h"


#define SRLogDebug(format, ...)
//#define SRLogDebug(format, ...) NSLog(format, __VA_ARGS__)

@interface SRTAutobahnTests : XCTestCase
@end

@interface TestOperation : SRTWebSocketOperation <SRWebSocketDelegate>
- (id)initWithBaseURL:(NSURL *)url testNumber:(NSInteger)testNumber agent:(NSString *)agent;
@end


@interface CaseGetterOperation : SRTWebSocketOperation <SRWebSocketDelegate>
- (id)initWithBaseURL:(NSURL *)url;

@property (nonatomic, readonly) NSInteger caseCount;

@end

@interface NSInvocation (SRTBlockInvocation)

+ (NSInvocation *)invocationWithBlock:(dispatch_block_t)block;

@end

@interface SRTBlockInvoker

- (id)initWithBlock:(dispatch_block_t)block;

- (void)invoke;

@end

@interface UpdateOperation : SRTWebSocketOperation <SRWebSocketDelegate>

- (id)initWithBaseURL:(NSURL *)url agent:(NSString *)agent;

@end

@interface TestInfoOperation : SRTWebSocketOperation <SRWebSocketDelegate>

@property (nonatomic) NSDictionary *info;

- (id)initWithBaseURL:(NSURL *)url caseNumber:(NSInteger)caseNumber;

@end

@interface TestResultsOperation : SRTWebSocketOperation <SRWebSocketDelegate>

@property (nonatomic) NSDictionary *info;

- (id)initWithBaseURL:(NSURL *)url caseNumber:(NSInteger)caseNumber agent:(NSString *)agent;

@end

@implementation SRTAutobahnTests {
    SRWebSocket *_curWebSocket;
    NSInteger _testCount;
    NSInteger _curTest;
    NSMutableArray *_sockets;
    NSString *_testURLString;
    NSURL *_prefixURL;
    NSString *_agent;
    NSString *_description;
}

- (id)initWithInvocation:(NSInvocation *)anInvocation description:(NSString *)description;
{
    self = [self initWithInvocation:anInvocation];
    if (self) {
        _description = description;
    }
    return self;
}

- (id)initWithInvocation:(NSInvocation *)anInvocation;
{
    self = [super initWithInvocation:anInvocation];
    if (self) {
        _testURLString = [[NSProcessInfo processInfo].environment objectForKey:@"SR_TEST_URL"];
        _prefixURL = [NSURL URLWithString:_testURLString];
        _agent = [NSBundle bundleForClass:[self class]].bundleIdentifier;
    }
    return self;
}

- (NSUInteger)testCaseCount;
{
    if (self.invocation) {
        return [super testCaseCount];
    }
    
    CaseGetterOperation *caseGetter = [[CaseGetterOperation alloc] initWithBaseURL:_prefixURL];
    
    [caseGetter start];
    
    //    [self runCurrentRunLoopUntilTestPasses:^BOOL{
    //        return caseGetter.isFinished;
    //    } timeout:20.0];
    
    XCTAssertNil(caseGetter.error, @"CaseGetter should have successfully returned the number of testCases. Instead got error %@", caseGetter.error);
    
    NSInteger caseCount = caseGetter.caseCount;
    
    return caseCount;
}

- (BOOL)isEmpty;
{
    return NO;
}

- (void)performTest:(XCTestCaseRun *) aRun
{
    if (self.invocation) {
        [super performTest:aRun];
        return;
    }
    [aRun start];
    for (NSUInteger i = 1; i <= aRun.test.testCaseCount; i++) {
        SEL sel = @selector(performTestWithNumber:);
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[[self class] instanceMethodSignatureForSelector:sel]];
        
        invocation.selector = sel;
        invocation.target = self;
        
        [invocation setArgument:&i atIndex:2];
        
        NSString *description = [self caseDescriptionForCaseNumber:i];
        
        XCTestCase *testCase = [[[self class] alloc] initWithInvocation:invocation description:description];
        
        XCTestCaseRun *run = [[XCTestCaseRun alloc] initWithTest:testCase];
        
        [testCase performTest:run];
    }
    [aRun stop];
    
    [self updateReports];
}

- (NSInteger)testNum;
{
    NSInteger i;
    [self.invocation getArgument:&i atIndex:2];
    return i;
}

- (NSString *)caseDescriptionForCaseNumber:(NSInteger)caseNumber;
{
    TestInfoOperation *testInfoOperation = [[TestInfoOperation alloc] initWithBaseURL:_prefixURL caseNumber:caseNumber];
    
    [testInfoOperation start];
    
    //    [self runCurrentRunLoopUntilTestPasses:^BOOL{
    //        return testInfoOperation.isFinished;
    //    } timeout:60 * 60];
    
    XCTAssertNil(testInfoOperation.error, @"Updating the report should not have errored");
    
    return [NSString stringWithFormat:@"%@ - %@", [testInfoOperation.info objectForKey:@"id"], [testInfoOperation.info objectForKey:@"description"]];
}

- (NSString *)description;
{
    if (_description) {
        return _description;
    } else {
        return @"Autobahn Test Harness";
    }
}

+ (id) defaultTestSuite
{
    return [[[self class] alloc] init];
}

- (void)performTestWithNumber:(NSInteger)testNumber;
{
    NSOperationQueue *testQueue = [[NSOperationQueue alloc] init];
    
    testQueue.maxConcurrentOperationCount = 1;
    
    TestOperation *testOp = [[TestOperation alloc] initWithBaseURL:_prefixURL testNumber:testNumber agent:_agent];
    [testQueue addOperation:testOp];
    
    TestResultsOperation *resultOp = [[TestResultsOperation alloc] initWithBaseURL:_prefixURL caseNumber:testNumber agent:_agent];
    [resultOp addDependency:testOp];
    [testQueue addOperation:resultOp];
    
    testQueue.suspended = NO;
    
    //    [self runCurrentRunLoopUntilTestPasses:^BOOL{
    //        return resultOp.isFinished;
    //    } timeout:60 * 60];
    
    XCTAssertTrue(!testOp.error, @"Test operation should not have failed");
    XCTAssertEqualObjects(@"OK", [resultOp.info objectForKey:@"behavior"], @"Test behavior should be OK");
}

- (void)updateReports;
{
    UpdateOperation *updateReportOperation = [[UpdateOperation alloc] initWithBaseURL:_prefixURL agent:_agent];
    
    [updateReportOperation start];
    
    //    [self runCurrentRunLoopUntilTestPasses:^BOOL{
    //        return updateReportOperation.isFinished;
    //    } timeout:60 * 60];
    
    XCTAssertNil(updateReportOperation.error, @"Updating the report should not have errored");
}

@end

@implementation TestOperation {
    NSInteger _testNumber;
}

- (id)initWithBaseURL:(NSURL *)url testNumber:(NSInteger)testNumber agent:(NSString *)agent;
{
    
    NSString *path = [[url URLByAppendingPathComponent:@"runCase"] absoluteString];
    path = [path stringByAppendingFormat:@"?case=%@&agent=%@", @(testNumber), agent];
    
    self = [super initWithURL:[NSURL URLWithString:path]];
    if (self) {
        _testNumber = testNumber;
    }
    return self;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;
{
    [webSocket send:message];
}

@end


@implementation CaseGetterOperation

@synthesize caseCount = _caseCount;

- (id)initWithBaseURL:(NSURL *)url;
{
    self = [super initWithURL:[url URLByAppendingPathComponent:@"getCaseCount"]];
    if (self) {
    }
    return self;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;
{
    _caseCount = [message integerValue];
}

@end


@implementation UpdateOperation

- (id)initWithBaseURL:(NSURL *)url agent:(NSString *)agent;
{
    NSString *path = [[url URLByAppendingPathComponent:@"updateReports"] absoluteString];
    path = [path stringByAppendingFormat:@"?agent=%@", agent];
    
    return [super initWithURL:[NSURL URLWithString:path]];
}

- (void)start;
{
    [super start];
    NSLog(@"Updating Reports!");
}

@end


@implementation TestInfoOperation

@synthesize info = _info;

- (id)initWithBaseURL:(NSURL *)url caseNumber:(NSInteger)caseNumber;
{
    NSString *path = [[url URLByAppendingPathComponent:@"getCaseInfo"] absoluteString];
    path = [path stringByAppendingFormat:@"?case=%@", @(caseNumber)];
    
    return [super initWithURL:[NSURL URLWithString:path]];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(NSString *)message;
{
    self.info = [NSJSONSerialization JSONObjectWithData:[message dataUsingEncoding:NSUTF8StringEncoding] options:0 error:NULL];
}

@end


@implementation TestResultsOperation

@synthesize info = _info;

- (id)initWithBaseURL:(NSURL *)url caseNumber:(NSInteger)caseNumber agent:(NSString *)agent;
{
    NSString *path = [[url URLByAppendingPathComponent:@"getCaseStatus"] absoluteString];
    path = [path stringByAppendingFormat:@"?case=%@&agent=%@", @(caseNumber), agent];
    
    return [super initWithURL:[NSURL URLWithString:path]];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(NSString *)message;
{
    self.info = [NSJSONSerialization JSONObjectWithData:[message dataUsingEncoding:NSUTF8StringEncoding] options:0 error:NULL];
}
@end
