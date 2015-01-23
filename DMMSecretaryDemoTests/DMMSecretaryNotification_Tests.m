//
//  DMMSecretaryNotification_Tests.m
//  DMMSecretaryDemo
//
//  Created by Daniel on 1/19/15.
//  Copyright (c) 2015 Daniel Miedema. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "TestObject.h"
#import "DMMSecretaryNotification.h"


@interface DMMSecretaryNotification_Tests : XCTestCase
@property (strong, nonatomic) TestObject *obj;
@end

@implementation DMMSecretaryNotification_Tests

- (void)testObserverSetCorrectly {
    DMMSecretaryNotification *notifcation = [DMMSecretaryNotification secretaryNotificationWithObserver:self.obj selector:@selector(testMethod) name:TestNotification object:nil];
    
    XCTAssertEqualObjects(self.obj, notifcation.observer, @"notificatoin.observer should equal self.obj. %@ - %@", self.obj, notifcation.observer);
}

- (void)testConvienceCreation {
    DMMSecretaryNotification *notifcation = [DMMSecretaryNotification secretaryNotificationWithObserver:self.obj selector:@selector(testMethod) name:TestNotification object:nil];
    
    XCTAssertEqualObjects(self.obj, notifcation.observer, @"notificatoin.observer should equal self.obj. %@ - %@", self.obj, notifcation.observer);
    XCTAssertTrue(@selector(testMethod) == notifcation.selector, @"Selectors should be equal");
    XCTAssertTrue([TestNotification isEqualToString:notifcation.name], @"names should be identical");
    XCTAssertNil(notifcation.object, @"object should equal what was passed in");
}

- (void)testFailWithNilObserver {
    // Because the compiler gets mad when we pass `nil` in
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    XCTAssertThrows([DMMSecretaryNotification secretaryNotificationWithObserver:nil selector:@selector(testMethod) name:TestNotification object:nil], @"Creating with nil observers should throw an error");
#pragma clang diagnostic pop
}

- (void)testCallingInitDirectlyThrowsExpection {
    XCTAssertThrows([[DMMSecretaryNotification alloc] init], @"Calling init on DMMSecretaryNotification should throw an exception");
}


#pragma mark - Setup
- (void)setUp {
    [super setUp];
    self.obj = [TestObject new];
}

- (void)tearDown {
    [super tearDown];
}
@end
