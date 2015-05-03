//
//  DMMSecretary_Tests.m
//  DMMSecretaryDemo
//
//  Created by Daniel on 1/19/15.
//  Copyright (c) 2015 Daniel Miedema. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "TestObject.h"
#import "DMMSecretary.h"
#import "DMMSecretaryInbox.h"

@interface DMMSecretary (Tests)
- (void)cleanUpSecretary;
+ (instancetype)sharedSecretary;
@end

@implementation DMMSecretary (Tests)
- (void)cleanUpSecretary {
    [[DMMSecretary sharedSecretary] setValue:[NSMutableDictionary dictionary] forKey:@"inboxes"];
}
@end

@interface DMMSecretary_Tests : XCTestCase
@property (strong, nonatomic) TestObject *obj;
@end

@implementation DMMSecretary_Tests
- (void)testCreatesInboxWhenAsked {
    NSDictionary *inboxes = [[DMMSecretary sharedSecretary] valueForKey:@"inboxes"];
    
    XCTAssertTrue([inboxes.allKeys containsObject:TestInbox], @"inboxes should contain key for %@", TestInbox);
}

- (void)testRemovesInbox {
    [DMMSecretary removeInbox:TestInbox];
    NSDictionary *inboxes = [[DMMSecretary sharedSecretary] valueForKey:@"inboxes"];
    
    XCTAssertFalse([inboxes.allKeys containsObject:TestInbox], @"inboxes should not contain key for %@", TestInbox);
}

- (void)testPrivateQueueExists {
    dispatch_queue_t queue = [[DMMSecretary sharedSecretary] valueForKey:@"_secretaryQueue"];
    NSString *queueLabel = [NSString stringWithUTF8String:dispatch_queue_get_label(queue)];
    
    XCTAssertTrue([queueLabel isEqualToString:@"DMMSecretaryQueue"], @"Queue label should equal 'DMMSecretaryQueue'. Instead was %@", queueLabel);
}

- (void)testKeepsTrackOfObservedNotifications {
    [DMMSecretary addNotification:CreateTestNotification(self.obj) toInbox:TestInbox];
    
    NSArray *observed = [DMMSecretary notificationsObservedByInbox:TestInbox];
    
    XCTAssertTrue([observed containsObject:TestNotification], @"Observed notifications for %@ should contain %@", TestInbox, TestNotification);
}

- (void)testRemovesNotificationsFromInboxes {
    [DMMSecretary addNotification:CreateTestNotification(self.obj) toInbox:TestInbox];
    
    [DMMSecretary removeNotification:TestNotification fromInbox:TestInbox];
    
    NSArray *observed = [DMMSecretary notificationsObservedByInbox:TestInbox];
    XCTAssertTrue(observed.count == 0, @"Observed notifications should be empty after removing %@", TestNotification);
}

- (void)testHoldsReceivedNotifications {
    id mock = [OCMockObject mockForClass:TestObject.class];
    
    [DMMSecretary addNotification:CreateTestNotification(mock) toInbox:TestInbox];
    
    [DMMSecretary startHoldingMessagesForInbox:TestInbox];
    
    [[mock expect] testMethod];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TestNotification object:nil];
    
    NSArray *held = [DMMSecretary notificationsForInbox:TestInbox];
    XCTAssertTrue(held.count > 0, @"Notifications for inbox should have more than 0 items.");
    XCTAssertTrue([held.firstObject isKindOfClass:NSNotification.class], @"Held item should be of type NSNotification. Was type %@", NSStringFromClass(held.class));
}

- (void)testHoldsNotifications {
    id mock = [OCMockObject mockForClass:TestObject.class];
    
    [DMMSecretary addNotification:CreateTestNotification(mock) toInbox:TestInbox];
    
    [DMMSecretary startHoldingMessagesForInbox:TestInbox];
    
    [[mock expect] testMethod];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TestNotification object:nil];
    
    XCTAssertThrows([mock verify], @"mock should not have received %@", TestNotification);
}

- (void)testOnlyHoldsUniques {
    id mock = [OCMockObject mockForClass:TestObject.class];
    
    [DMMSecretary addNotification:CreateTestNotification(mock) toInbox:TestInbox];
    
    [DMMSecretary startHoldingMessagesForInbox:TestInbox];
    [DMMSecretary onlyKeepUniqueMessages:YES forInboxIdentifier:TestInbox];
    [[mock expect] testMethod];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TestNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:TestNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:TestNotification object:nil];
    
    NSArray *heldNotifications = [DMMSecretary notificationsForInbox:TestInbox];
    
    XCTAssertTrue(heldNotifications.count == 1, @"heldNotifications should only have 1 item. Instead had %li", heldNotifications.count);
}

- (void)testStopsHoldingNotifications {
    id mock = [OCMockObject mockForClass:TestObject.class];
    
    [DMMSecretary addNotification:CreateTestNotification(mock) toInbox:TestInbox];
    
    [DMMSecretary startHoldingMessagesForInbox:TestInbox];
    
    [[mock expect] testMethod];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TestNotification object:nil];
    
    XCTAssertThrows([mock verify], @"mock should not have received %@", TestNotification);
    
    [DMMSecretary stopHoldingMessagesForInbox:TestInbox];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TestNotification object:nil];

    XCTAssertNoThrow([mock verify], @"mock should have received %@ after turning off holding", TestNotification);
}


- (void)testPassesHeldNotifications {
    id mock = [OCMockObject mockForClass:TestObject.class];
    
    [DMMSecretary addNotification:CreateTestNotification(mock) toInbox:TestInbox];
    
    [DMMSecretary startHoldingMessagesForInbox:TestInbox];
    
    [[mock expect] testMethod];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TestNotification object:nil];
    
    XCTAssertThrows([mock verify], @"mock should not have received %@", TestNotification);
    
    [DMMSecretary sendHeldNotificationsForInbox:TestInbox];
    
    XCTAssertNoThrow([mock verify], @"mock should have received %@ after turning off holding", TestNotification);
}

- (void)testCreatingExistingInbox {
    [DMMSecretary addNotification:CreateTestNotification(self.obj) toInbox:TestInbox];
    
    [DMMSecretary createInbox:TestInbox notifications:@[]];
    
    NSArray *observed = [DMMSecretary notificationsObservedByInbox:TestInbox];
    XCTAssertTrue(observed.count > 0, @"Creating an inbox that already exists should not overwrite existing inbox");
}

- (void)testDroppingAllNotifications {
    id mock = [OCMockObject mockForClass:TestObject.class];

    [DMMSecretary addNotification:CreateTestNotification(mock) toInbox:TestInbox];

    [DMMSecretary startHoldingMessagesForInbox:TestInbox];

    [[NSNotificationCenter defaultCenter] postNotificationName:TestNotification object:nil];

    [DMMSecretary dropAllHeldNotificationsForInbox:TestInbox];

    XCTAssertNoThrow([mock verify], @"mock should not have received %@ after dropping all notifications", TestNotification);
}

- (void)testDroppingNotificationsByName {
    id mock = [OCMockObject mockForClass:TestObject.class];
    id anotherMock = [OCMockObject mockForClass:TestObject.class];

    [DMMSecretary addNotification:CreateTestNotification(mock) toInbox:TestInbox];

    [DMMSecretary addNotification:[DMMSecretaryNotification secretaryNotificationWithObserver:anotherMock selector:@selector(anotherTestMethod) name:AnotherTestNotification object:nil] toInbox:TestInbox];

    [DMMSecretary startHoldingMessagesForInbox:TestInbox];

    [[NSNotificationCenter defaultCenter] postNotificationName:TestNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:AnotherTestNotification object:nil];

    [[mock expect] testMethod];
    [[anotherMock expect] anotherTestMethod];

    [DMMSecretary dropAllHeldNotifications:AnotherTestNotification forInboxIdentifier:TestInbox];
    [DMMSecretary sendHeldNotificationsForInbox:TestInbox];

    XCTAssertNoThrow([mock verify], @"mock should have received %@", TestNotification);

    XCTAssertThrows([anotherMock verify], @"anotherMock should have not received %@ after dropping '%@' notificiations", AnotherTestNotification, AnotherTestNotification);
}

- (void)testChangingObserver {
    id mock = [OCMockObject mockForClass:TestObject.class];
    id anotherMock = [OCMockObject mockForClass:TestObject.class];

    [DMMSecretary addNotification:CreateTestNotification(mock) toInbox:TestInbox];

    [DMMSecretary startHoldingMessagesForInbox:TestInbox];

    [[mock expect] testMethod];
    [[anotherMock expect] testMethod];

    [DMMSecretary changeObserverTo:anotherMock forNotification:TestNotification inInbox:TestInbox];

    [[NSNotificationCenter defaultCenter] postNotificationName:TestNotification object:nil];
    [DMMSecretary sendHeldNotificationsForInbox:TestInbox];

    XCTAssertThrows([mock verify], @"mock should have not have received %@", TestNotification);

    XCTAssertNoThrow([anotherMock verify], @"anotherMock should have received %@", AnotherTestNotification);
}

#pragma mark - Setup
- (void)setUp {
    self.obj = [TestObject new];
    
    [DMMSecretary createInbox:TestInbox notifications:@[]];
    
    [super setUp];
}

- (void)tearDown {
    [[DMMSecretary sharedSecretary] cleanUpSecretary];
    self.obj = nil;
    [super tearDown];
}

@end
