//
//  DMMSecretaryInbox_Tests.m
//  DMMSecretaryDemo
//
//  Created by Daniel on 1/19/15.
//  Copyright (c) 2015 Daniel Miedema. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "TestObject.h"
#import "DMMSecretaryInbox.h"
#import "DMMSecretaryNotification.h"

DMMSecretaryNotification * __TestNotificationWithNullSelector(void) {
    // Because the compiler gets mad when we pass `nil` in
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    return [DMMSecretaryNotification secretaryNotificationWithObserver:[NSObject new] selector:nil name:TestNotification object:nil];
#pragma clang diagnostic pop
}

void AddTestNotificationToInbox(DMMSecretaryInbox *inbox) {
    [inbox addNotificationToNotifications:__TestNotificationWithNullSelector()];
}

@interface DMMSecretaryInbox_Tests : XCTestCase
@property (strong, nonatomic) DMMSecretaryInbox *inbox;
@end

@implementation DMMSecretaryInbox_Tests

- (void)testAddingNotificationToNotifications {
    AddTestNotificationToInbox(self.inbox);
    
    XCTAssertTrue([[self.inbox observedNotificationNames] containsObject:TestNotification], @"inbox observed notifications should contain %@", TestNotification);
}

- (void)testHoldingNotificationsWorks {
    self.inbox.holdMessages = YES;
    
    AddTestNotificationToInbox(self.inbox);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TestNotification object:nil];
    
    NSArray *heldNotifications = [self.inbox valueForKey:@"heldNotifications"];
    
    NSNotification *notification = heldNotifications.firstObject;
    
    XCTAssertTrue([notification.name isEqualToString:TestNotification], @"heldNotifications should contain an NSNotification with name: %@, Instead was %@", TestNotification, notification.name);
}

- (void)testRevovingNotifications {
    AddTestNotificationToInbox(self.inbox);
    
    XCTAssertTrue([[self.inbox observedNotificationNames] containsObject:TestNotification], @"inbox observed notifications should contain %@", TestNotification);
    
    [self.inbox removeNotificationFromNotifications:TestNotification];
    
    XCTAssertTrue(![[self.inbox observedNotificationNames] containsObject:TestNotification], @"inbox observed notifications should not contain %@", TestNotification);
}

- (void)testSendingHeldNotifications {
    id mock = [OCMockObject mockForClass:TestObject.class];

    [self.inbox addNotificationToNotifications:[DMMSecretaryNotification secretaryNotificationWithObserver:mock selector:@selector(testMethod) name:TestNotification object:nil]];
    
    [[mock expect] testMethod];
    
    self.inbox.holdMessages = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:TestNotification object:nil];
    
    XCTAssertThrows([mock verify], @"Should not have called 'notificationSent'");
    
    [self.inbox sendHeldNotifications];
    XCTAssertNoThrow([mock verify], @"Should not called 'notificationSent'");
    
}

#pragma mark - Setup
- (void)setUp {
    [super setUp];
    self.inbox = [DMMSecretaryInbox inboxWithIdentifier:TestInbox];
}

- (void)tearDown {
    self.inbox = nil;
    [super tearDown];
}

@end
