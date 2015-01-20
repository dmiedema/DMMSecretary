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
#import "DMMSecretaryInbox.h"
#import "DMMSecretaryNotification.h"

NSString * const InboxIdentifier = @"InboxIdentifier";
NSString * const NotificationIdentifier = @"NotificationIdentifier";

DMMSecretaryNotification * TestNotification(void) {
    return [DMMSecretaryNotification secretaryNotificationWithObserver:[NSObject new] selector:nil name:NotificationIdentifier object:nil];
}

void AddTestNotificationToInbox(DMMSecretaryInbox *inbox) {
    [inbox addNotificationToNotifications:TestNotification()];
}

@interface TestObject : NSObject
- (void)notificationSent;
@end
@implementation TestObject
- (void)notificationSent {}
@end

@interface DMMSecretaryInbox_Tests : XCTestCase
@property (strong, nonatomic) DMMSecretaryInbox *inbox;
@end

@implementation DMMSecretaryInbox_Tests

- (void)testAddingNotificationToNotifications {
    AddTestNotificationToInbox(self.inbox);
    
    XCTAssertTrue([[self.inbox observedNotificationNames] containsObject:NotificationIdentifier], @"inbox observed notifications should contain %@", NotificationIdentifier);
}

- (void)testHoldingNotificationsWorks {
    self.inbox.holdMessages = YES;
    
    AddTestNotificationToInbox(self.inbox);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationIdentifier object:nil];
    
    NSArray *heldNotifications = [self.inbox valueForKey:@"heldNotifications"];
    
    NSNotification *notification = heldNotifications.firstObject;
    
    XCTAssertTrue([notification.name isEqualToString:NotificationIdentifier], @"heldNotifications should contain an NSNotification with name: %@, Instead was %@", NotificationIdentifier, notification.name);
}

- (void)testRevovingNotifications {
    AddTestNotificationToInbox(self.inbox);
    
    XCTAssertTrue([[self.inbox observedNotificationNames] containsObject:NotificationIdentifier], @"inbox observed notifications should contain %@", NotificationIdentifier);
    
    [self.inbox removeNotificationFromNotifications:NotificationIdentifier];
    
    XCTAssertTrue(![[self.inbox observedNotificationNames] containsObject:NotificationIdentifier], @"inbox observed notifications should not contain %@", NotificationIdentifier);
    
}

- (void)testSendingHeldNotifications {
    id mock = [OCMockObject mockForClass:TestObject.class];

    [self.inbox addNotificationToNotifications:[DMMSecretaryNotification secretaryNotificationWithObserver:mock selector:@selector(notificationSent) name:NotificationIdentifier object:nil]];
    
    [[mock expect] notificationSent];
    
    self.inbox.holdMessages = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationIdentifier object:nil];
    
    XCTAssertThrows([mock verify], @"Should not have called 'notificationSent'");
    
    [self.inbox sendHeldNotifications];
    XCTAssertNoThrow([mock verify], @"Should not called 'notificationSent'");
    
}

#pragma mark - Setup
- (void)setUp {
    [super setUp];
    self.inbox = [DMMSecretaryInbox inboxWithIdentifier:InboxIdentifier];
}

- (void)tearDown {
    self.inbox = nil;
    [super tearDown];
}

@end
